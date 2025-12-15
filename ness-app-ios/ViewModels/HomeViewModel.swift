//
//  HomeViewModel.swift
//  ness-app-ios
//

import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var wallets: [Wallet] = []
    @Published var transactions: [Transaction] = []
    @Published var totalBalance: Double = 0
    @Published var isLoading = false
    @Published var error: NessError?
    
    @Published var showSend = false
    @Published var showReceive = false
    @Published var showPaymentRequired = false
    @Published var pendingPayment: PaymentRequired?
    
    private let webSocket = WebSocketService()
    
    var primaryWallet: Wallet? {
        wallets.first { $0.isPrimary } ?? wallets.first
    }
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            wallets = try await webSocket.listWallets()
            transactions = try await webSocket.listTransactions()
            
            // Get balance for primary wallet
            if let wallet = primaryWallet {
                let balance = try await webSocket.getWalletBalance(address: wallet.address)
                totalBalance = balance.sol
            }
        } catch {
            self.error = error as? NessError ?? .unknown(error.localizedDescription)
        }
    }
    
    func refresh() async {
        await load()
    }
    
    func requestVideoGeneration() {
        Task {
            do {
                let payment = try await webSocket.requestService(serviceId: "veo3-video-8s")
                pendingPayment = payment
                showPaymentRequired = true
            } catch {
                self.error = error as? NessError ?? .unknown(error.localizedDescription)
            }
        }
    }
    
    func confirmPayment() {
        // In production:
        // 1. Create Solana transaction
        // 2. Sign with Privy wallet (triggers biometric MFA)
        // 3. Submit transaction
        // 4. Send payment proof to backend
        
        showPaymentRequired = false
        pendingPayment = nil
    }
}
