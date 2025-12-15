//
//  PaymentRequiredSheet.swift
//  ness-app-ios
//

import SwiftUI

struct PaymentRequiredSheet: View {
    let payment: PaymentRequired
    let onConfirm: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.orange)
                
                Text("Payment Required")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .padding(.top)
            
            // Service info
            VStack(spacing: 16) {
                InfoRow(label: "Service", value: payment.description)
                InfoRow(label: "Amount", value: "\(payment.amountSol) \(payment.currency)")
                InfoRow(label: "To", value: shortenAddress(payment.paymentAddress))
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(12)
            
            // x402 badge
            HStack {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundColor(.green)
                Text("Powered by x402 Protocol")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Actions
            VStack(spacing: 12) {
                Button(action: {
                    onConfirm()
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "faceid")
                        Text("Pay with Face ID")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.secondary)
            }
        }
        .padding()
    }
    
    private func shortenAddress(_ address: String) -> String {
        guard address.count > 12 else { return address }
        return "\(address.prefix(6))...\(address.suffix(4))"
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    PaymentRequiredSheet(
        payment: PaymentRequired(
            paymentAddress: "ABC123...XYZ",
            amountLamports: 50_000_000,
            amountSol: 0.05,
            currency: "SOL",
            description: "Veo3 8-second Video Generation",
            resourceId: "veo3:123",
            expiresAt: 0
        ),
        onConfirm: {}
    )
}
