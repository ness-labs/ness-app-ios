//
//  NessError.swift
//  ness-app-ios
//

import Foundation

enum NessError: Error, LocalizedError {
    case unauthorized
    case mfaRequired
    case userNotFound(String)
    case walletNotFound(String)
    case insufficientBalance(required: Double, available: Double)
    case paymentRequired(String)
    case networkError(Error)
    case privyError(String)
    case solanaError(String)
    case websocketDisconnected
    case invalidResponse
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Authentication required"
        case .mfaRequired:
            return "Biometric verification required"
        case .userNotFound(let id):
            return "User not found: \(id)"
        case .walletNotFound(let address):
            return "Wallet not found: \(address)"
        case .insufficientBalance(let required, let available):
            return "Insufficient balance: need \(required) SOL, have \(available) SOL"
        case .paymentRequired(let service):
            return "Payment required for: \(service)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .privyError(let message):
            return "Privy error: \(message)"
        case .solanaError(let message):
            return "Solana error: \(message)"
        case .websocketDisconnected:
            return "Connection lost"
        case .invalidResponse:
            return "Invalid server response"
        case .unknown(let message):
            return message
        }
    }
}

struct ErrorResponse: Codable {
    let error: ErrorDetail
    
    struct ErrorDetail: Codable {
        let code: String
        let httpStatus: Int?
        let message: String
    }
}
