//
//  User.swift
//  ness-app-ios
//

import Foundation

struct NessUser: Codable, Identifiable {
    let id: UUID
    let privyUserId: String
    var email: String?
    var tag: String?
    var preferredFiat: String
    var preferredStable: String
    let createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case privyUserId = "privy_user_id"
        case email, tag
        case preferredFiat = "preferred_fiat"
        case preferredStable = "preferred_stable"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct Wallet: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let privyWalletId: String
    let address: String
    let chainType: String
    var label: String?
    let isPrimary: Bool
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case privyWalletId = "privy_wallet_id"
        case address
        case chainType = "chain_type"
        case label
        case isPrimary = "is_primary"
        case createdAt = "created_at"
    }
}

struct Transaction: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let walletId: UUID
    let signature: String
    let txType: String
    let status: String
    let amountLamports: Int64
    let toAddress: String
    var description: String?
    var serviceId: String?
    let createdAt: Date
    var confirmedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case walletId = "wallet_id"
        case signature
        case txType = "tx_type"
        case status
        case amountLamports = "amount_lamports"
        case toAddress = "to_address"
        case description
        case serviceId = "service_id"
        case createdAt = "created_at"
        case confirmedAt = "confirmed_at"
    }
    
    var solAmount: Double {
        Double(amountLamports) / 1_000_000_000.0
    }
}
