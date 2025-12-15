//
//  WebSocketService.swift
//  ness-app-ios
//

import Foundation
import Combine

@MainActor
class WebSocketService: ObservableObject {
    @Published var isConnected = false
    @Published var isAuthenticated = false
    @Published var lastError: NessError?
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession
    private var serverURL: URL
    
    private var messageHandlers: [String: (Data) -> Void] = [:]
    private var pendingRequests: [String: CheckedContinuation<Data, Error>] = [:]
    
    init(serverURL: URL = URL(string: "wss://api.ness.app/ws")!) {
        self.serverURL = serverURL
        self.session = URLSession(configuration: .default)
    }
    
    func connect() {
        guard webSocketTask == nil else { return }
        
        webSocketTask = session.webSocketTask(with: serverURL)
        webSocketTask?.resume()
        isConnected = true
        
        receiveMessages()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false
        isAuthenticated = false
    }
    
    func authenticate(token: String) async throws {
        let message = WsRequest(type: "auth", payload: ["token": token])
        let response = try await send(message)
        
        if let error = try? JSONDecoder().decode(ErrorResponse.self, from: response) {
            throw NessError.unauthorized
        }
        
        isAuthenticated = true
    }
    
    func getWalletBalance(address: String) async throws -> WalletBalance {
        let message = WsRequest(type: "wallet.balance", payload: ["address": address])
        let response = try await send(message)
        
        let wsResponse = try JSONDecoder().decode(WsResponse<WalletBalance>.self, from: response)
        return wsResponse.payload
    }
    
    func listWallets() async throws -> [Wallet] {
        let message = WsRequest(type: "wallet.list", payload: [:])
        let response = try await send(message)
        
        let wsResponse = try JSONDecoder().decode(WsResponse<WalletsPayload>.self, from: response)
        return wsResponse.payload.wallets
    }
    
    func listTransactions(limit: Int = 20) async throws -> [Transaction] {
        let message = WsRequest(type: "transaction.list", payload: ["limit": limit])
        let response = try await send(message)
        
        let wsResponse = try JSONDecoder().decode(WsResponse<TransactionsPayload>.self, from: response)
        return wsResponse.payload.transactions
    }
    
    func requestService(serviceId: String, params: [String: Any] = [:]) async throws -> PaymentRequired {
        let message = WsRequest(type: "service.request", payload: [
            "service_id": serviceId,
            "params": params
        ])
        let response = try await send(message)
        
        let wsResponse = try JSONDecoder().decode(WsResponse<PaymentRequired>.self, from: response)
        return wsResponse.payload
    }
    
    private func send(_ request: WsRequest) async throws -> Data {
        guard let task = webSocketTask else {
            throw NessError.websocketDisconnected
        }
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let message = URLSessionWebSocketTask.Message.data(data)
        
        try await task.send(message)
        
        // Wait for response
        return try await withCheckedThrowingContinuation { continuation in
            pendingRequests[request.type] = continuation
        }
    }
    
    private func receiveMessages() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                Task { @MainActor in
                    self.handleMessage(message)
                    self.receiveMessages()
                }
            case .failure(let error):
                Task { @MainActor in
                    self.lastError = .networkError(error)
                    self.isConnected = false
                }
            }
        }
    }
    
    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        let data: Data
        switch message {
        case .data(let d):
            data = d
        case .string(let s):
            data = s.data(using: .utf8) ?? Data()
        @unknown default:
            return
        }
        
        // Try to parse message type
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let type = json["type"] as? String {
            
            // Check for pending request
            if let continuation = pendingRequests.removeValue(forKey: type.replacingOccurrences(of: ".success", with: "")) {
                continuation.resume(returning: data)
            }
            
            // Call registered handler
            messageHandlers[type]?(data)
        }
    }
    
    func onMessage(_ type: String, handler: @escaping (Data) -> Void) {
        messageHandlers[type] = handler
    }
}

// MARK: - WebSocket Types

struct WsRequest: Encodable {
    let type: String
    let payload: [String: Any]
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        
        let payloadData = try JSONSerialization.data(withJSONObject: payload)
        let payloadJSON = try JSONSerialization.jsonObject(with: payloadData)
        try container.encode(AnyCodable(payloadJSON), forKey: .payload)
    }
    
    enum CodingKeys: String, CodingKey {
        case type, payload
    }
}

struct WsResponse<T: Decodable>: Decodable {
    let type: String
    let payload: T
    let timestamp: String
}

struct WalletBalance: Codable {
    let address: String
    let lamports: UInt64
    let sol: Double
}

struct WalletsPayload: Codable {
    let wallets: [Wallet]
}

struct TransactionsPayload: Codable {
    let transactions: [Transaction]
}

struct PaymentRequired: Codable {
    let paymentAddress: String
    let amountLamports: UInt64
    let amountSol: Double
    let currency: String
    let description: String
    let resourceId: String
    let expiresAt: Int64
    
    enum CodingKeys: String, CodingKey {
        case paymentAddress = "payment_address"
        case amountLamports = "amount_lamports"
        case amountSol = "amount_sol"
        case currency, description
        case resourceId = "resource_id"
        case expiresAt = "expires_at"
    }
}

// Helper for encoding Any
struct AnyCodable: Encodable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let string as String:
            try container.encode(string)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let bool as Bool:
            try container.encode(bool)
        case let dict as [String: Any]:
            let encoded = dict.mapValues { AnyCodable($0) }
            try container.encode(encoded)
        case let array as [Any]:
            let encoded = array.map { AnyCodable($0) }
            try container.encode(encoded)
        default:
            try container.encodeNil()
        }
    }
}
