//
//  AuthView.swift
//  ness-app-ios
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Logo
            VStack(spacing: 16) {
                Image(systemName: "wallet.pass.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue.gradient)
                
                Text("Ness")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Pay anywhere with x402")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Auth buttons
            VStack(spacing: 16) {
                Button(action: signUp) {
                    HStack {
                        Image(systemName: "faceid")
                        Text("Create Account")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Button(action: signIn) {
                    HStack {
                        Image(systemName: "person.fill")
                        Text("Sign In")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.secondary.opacity(0.2))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 32)
            .disabled(isLoading)
            
            if isLoading {
                ProgressView()
            }
            
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func signUp() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await authManager.signUp()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    private func signIn() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await authManager.signIn()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthManager())
}
