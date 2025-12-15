//
//  ContentView.swift
//  ness-app-ios
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthManager()
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                if authManager.needsOnboarding {
                    OnboardingView()
                } else {
                    HomeView()
                }
            } else {
                AuthView()
            }
        }
        .environmentObject(authManager)
        .task {
            await authManager.checkAuth()
        }
    }
}

#Preview {
    ContentView()
}
