# ness-app-ios - iOS Application

SwiftUI iOS app for the Ness payment platform.

## Overview

Features:
- Passkey/biometric authentication via Privy
- Multiple Solana wallet management
- Real-time balance updates via WebSocket
- x402 payment flow with Face ID confirmation
- Transaction history with Solana Explorer links

## Requirements

- iOS 17+
- Xcode 15+
- Privy Swift SDK

## Setup

1. Open `ness-app-ios.xcodeproj` in Xcode

2. Add Privy SDK via Swift Package Manager:
   ```
   https://github.com/privy-io/privy-ios
   ```

3. Configure your Privy App ID in the app

4. Set up Associated Domains for passkeys:
   - Add `webcredentials:your-domain.com` to entitlements
   - Host `.well-known/apple-app-site-association` on your domain

## Architecture

```
Views/
├── AuthView.swift           # Login/signup screen
├── OnboardingView.swift     # Tag and preferences setup
├── HomeView.swift           # Main dashboard
├── PaymentRequiredSheet.swift # x402 payment confirmation
├── TransactionListView.swift  # Transaction history
└── SettingsView.swift       # User settings

ViewModels/
└── HomeViewModel.swift      # Home screen logic

Services/
├── AuthManager.swift        # Privy authentication
├── WebSocketService.swift   # Real-time communication
└── NessError.swift          # Error types

Models/
└── User.swift               # Data models
```

## User Flow

### Authentication

1. User opens app
2. Chooses "Create Account" or "Sign In"
3. Authenticates with Face ID/Touch ID (passkey)
4. Privy creates/retrieves user with stable DID

### Onboarding (new users)

1. Choose unique tag (@username)
2. Select preferred fiat currency (USD/EUR/GBP)
3. Select preferred stablecoin (USDC/EURC)
4. Solana wallet auto-created

### Main App

- View total balance across wallets
- Send/receive SOL
- Request AI services (triggers x402 payment)
- View transaction history
- Manage multiple wallets

### x402 Payment

1. User requests paid service (e.g., AI video)
2. App shows payment sheet with amount
3. User confirms with Face ID
4. Privy signs Solana transaction
5. Backend verifies payment
6. Service delivered

## WebSocket Messages

### Outgoing (to server)

```swift
// Authenticate
{ "type": "auth", "payload": { "token": "jwt" } }

// Get balance
{ "type": "wallet.balance", "payload": { "address": "..." } }

// Request service
{ "type": "service.request", "payload": { "service_id": "veo3-video-8s" } }
```

### Incoming (from server)

```swift
// Auth success
{ "type": "auth.success", "payload": { "userId": "did:privy:..." } }

// Balance update
{ "type": "balance.update", "payload": { "address": "...", "sol": 1.5 } }

// Payment required (x402)
{ "type": "payment.required", "payload": { "amount_sol": 0.05, ... } }
```

## Key Components

### AuthManager

Handles Privy authentication:

```swift
@MainActor
class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: NessUser?
    
    func signUp() async throws {
        // Privy passkey signup
    }
    
    func signIn() async throws {
        // Privy passkey login
    }
}
```

### WebSocketService

Real-time communication:

```swift
@MainActor
class WebSocketService: ObservableObject {
    @Published var isConnected = false
    
    func connect()
    func authenticate(token: String) async throws
    func getWalletBalance(address: String) async throws -> WalletBalance
    func requestService(serviceId: String) async throws -> PaymentRequired
}
```

## Security

- All wallet operations require biometric MFA
- Private keys never leave Privy's secure enclave
- WebSocket authenticated with Privy JWT
- Sensitive data not logged

## Testing

```bash
# Run unit tests
xcodebuild test -scheme ness-app-ios -destination 'platform=iOS Simulator,name=iPhone 15'

# Run UI tests
xcodebuild test -scheme ness-app-iosUITests -destination 'platform=iOS Simulator,name=iPhone 15'
```
