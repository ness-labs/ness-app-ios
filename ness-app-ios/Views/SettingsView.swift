//
//  SettingsView.swift
//  ness-app-ios
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var tag = ""
    @State private var email = ""
    @State private var selectedFiat = "USD"
    @State private var selectedStable = "USDC"
    
    let fiatOptions = ["USD", "EUR", "GBP"]
    let stableOptions = ["USDC", "EURC"]
    
    var body: some View {
        List {
            Section("Profile") {
                TextField("Tag", text: $tag)
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
            }
            
            Section("Preferences") {
                Picker("Display Currency", selection: $selectedFiat) {
                    ForEach(fiatOptions, id: \.self) { Text($0) }
                }
                
                Picker("Preferred Stablecoin", selection: $selectedStable) {
                    ForEach(stableOptions, id: \.self) { Text($0) }
                }
            }
            
            Section("Wallets") {
                NavigationLink("Manage Wallets") {
                    WalletsView()
                }
            }
            
            Section("Security") {
                NavigationLink("Biometric Settings") {
                    Text("Biometric settings")
                }
            }
            
            Section {
                Button("Sign Out", role: .destructive) {
                    authManager.signOut()
                }
            }
            
            Section("About") {
                LabeledContent("Version", value: "1.0.0")
                Link("Privacy Policy", destination: URL(string: "https://ness.app/privacy")!)
                Link("Terms of Service", destination: URL(string: "https://ness.app/terms")!)
            }
        }
        .navigationTitle("Settings")
    }
}

struct WalletsView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.wallets) { wallet in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(wallet.label ?? "Wallet")
                            .fontWeight(.medium)
                        if wallet.isPrimary {
                            Text("Primary")
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                    Text(wallet.address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Button {
                // Create new wallet
            } label: {
                Label("Add Wallet", systemImage: "plus")
            }
        }
        .navigationTitle("Wallets")
        .task {
            await viewModel.load()
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AuthManager())
    }
}
