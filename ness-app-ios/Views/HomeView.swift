//
//  HomeView.swift
//  ness-app-ios
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Balance Card
                    BalanceCard(
                        balance: viewModel.totalBalance,
                        address: viewModel.primaryWallet?.address
                    )
                    
                    // Quick Actions
                    HStack(spacing: 16) {
                        ActionButton(icon: "arrow.up.circle.fill", title: "Send") {
                            viewModel.showSend = true
                        }
                        
                        ActionButton(icon: "arrow.down.circle.fill", title: "Receive") {
                            viewModel.showReceive = true
                        }
                        
                        ActionButton(icon: "sparkles", title: "AI Video") {
                            viewModel.requestVideoGeneration()
                        }
                    }
                    .padding(.horizontal)
                    
                    // Recent Transactions
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Recent Activity")
                                .font(.headline)
                            Spacer()
                            NavigationLink("See All") {
                                TransactionListView()
                            }
                            .font(.subheadline)
                        }
                        .padding(.horizontal)
                        
                        if viewModel.transactions.isEmpty {
                            Text("No transactions yet")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            ForEach(viewModel.transactions.prefix(5)) { tx in
                                TransactionRow(transaction: tx)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Ness")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .sheet(isPresented: $viewModel.showPaymentRequired) {
                if let payment = viewModel.pendingPayment {
                    PaymentRequiredSheet(payment: payment) {
                        viewModel.confirmPayment()
                    }
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

struct BalanceCard: View {
    let balance: Double
    let address: String?
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Total Balance")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("\(balance, specifier: "%.4f") SOL")
                .font(.system(size: 36, weight: .bold, design: .rounded))
            
            if let address = address {
                Text(shortenAddress(address))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.1))
        )
        .padding(.horizontal)
    }
    
    private func shortenAddress(_ address: String) -> String {
        guard address.count > 12 else { return address }
        return "\(address.prefix(6))...\(address.suffix(4))"
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            Image(systemName: transaction.txType == "transfer" ? "arrow.up.right" : "sparkles")
                .foregroundColor(transaction.txType == "transfer" ? .orange : .purple)
                .frame(width: 32)
            
            VStack(alignment: .leading) {
                Text(transaction.description ?? transaction.txType.capitalized)
                    .font(.subheadline)
                Text(transaction.status.capitalized)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(transaction.solAmount, specifier: "%.4f") SOL")
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthManager())
}
