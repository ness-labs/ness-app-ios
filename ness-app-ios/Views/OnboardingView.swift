//
//  OnboardingView.swift
//  ness-app-ios
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var tag = ""
    @State private var selectedFiat = "USD"
    @State private var selectedStable = "USDC"
    @State private var isLoading = false
    @State private var currentStep = 0
    
    let fiatOptions = ["USD", "EUR", "GBP"]
    let stableOptions = ["USDC", "EURC"]
    
    var body: some View {
        VStack(spacing: 32) {
            // Progress
            HStack(spacing: 8) {
                ForEach(0..<3) { step in
                    Capsule()
                        .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                        .frame(height: 4)
                }
            }
            .padding(.horizontal)
            
            TabView(selection: $currentStep) {
                // Step 1: Choose tag
                VStack(spacing: 24) {
                    Image(systemName: "at")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Choose your tag")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("This is how others will find you")
                        .foregroundColor(.secondary)
                    
                    TextField("@username", text: $tag)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(.horizontal, 40)
                }
                .tag(0)
                
                // Step 2: Preferred currency
                VStack(spacing: 24) {
                    Image(systemName: "dollarsign.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Preferred currency")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("For displaying balances")
                        .foregroundColor(.secondary)
                    
                    Picker("Fiat", selection: $selectedFiat) {
                        ForEach(fiatOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 40)
                }
                .tag(1)
                
                // Step 3: Preferred stablecoin
                VStack(spacing: 24) {
                    Image(systemName: "bitcoinsign.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Preferred stablecoin")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("For payments and transfers")
                        .foregroundColor(.secondary)
                    
                    Picker("Stable", selection: $selectedStable) {
                        ForEach(stableOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 40)
                }
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            Spacer()
            
            // Navigation buttons
            HStack {
                if currentStep > 0 {
                    Button("Back") {
                        withAnimation {
                            currentStep -= 1
                        }
                    }
                }
                
                Spacer()
                
                Button(currentStep == 2 ? "Complete" : "Next") {
                    if currentStep == 2 {
                        completeOnboarding()
                    } else {
                        withAnimation {
                            currentStep += 1
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(currentStep == 0 && tag.isEmpty)
            }
            .padding(.horizontal, 32)
        }
        .padding(.vertical)
    }
    
    private func completeOnboarding() {
        isLoading = true
        Task {
            await authManager.completeOnboarding(
                tag: tag,
                preferredFiat: selectedFiat,
                preferredStable: selectedStable
            )
            isLoading = false
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AuthManager())
}
