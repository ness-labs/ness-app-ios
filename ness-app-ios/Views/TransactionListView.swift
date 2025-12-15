//
//  TransactionListView.swift
//  ness-app-ios
//

import SwiftUI

struct TransactionListView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        List(viewModel.transactions) { tx in
            NavigationLink {
                TransactionDetailView(transaction: tx)
            } label: {
                TransactionRow(transaction: tx)
            }
        }
        .navigationTitle("Transactions")
        .task {
            await viewModel.load()
        }
    }
}

struct TransactionDetailView: View {
    let transaction: Transaction
    
    var body: some View {
        List {
            Section("Details") {
                LabeledContent("Type", value: transaction.txType.capitalized)
                LabeledContent("Status", value: transaction.status.capitalized)
                LabeledContent("Amount", value: "\(transaction.solAmount) SOL")
                LabeledContent("To", value: shortenAddress(transaction.toAddress))
            }
            
            Section("Signature") {
                Text(transaction.signature)
                    .font(.system(.caption, design: .monospaced))
                    .textSelection(.enabled)
            }
            
            Section {
                Link(destination: explorerURL) {
                    HStack {
                        Text("View on Solana Explorer")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                    }
                }
            }
        }
        .navigationTitle("Transaction")
    }
    
    private var explorerURL: URL {
        URL(string: "https://explorer.solana.com/tx/\(transaction.signature)?cluster=devnet")!
    }
    
    private func shortenAddress(_ address: String) -> String {
        guard address.count > 12 else { return address }
        return "\(address.prefix(6))...\(address.suffix(4))"
    }
}

#Preview {
    NavigationStack {
        TransactionListView()
    }
}
