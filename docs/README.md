# ness-app-ios Documentation

iOS app for Ness — pay using x402 and agents.

## Tech Stack

- SwiftUI (iOS 17+)
- Privy Swift SDK (passkey auth, embedded wallets)
- WebSocket for real-time communication

## Setup

### 1. Install Privy SDK

Add via Swift Package Manager:
```
https://github.com/privy-io/privy-ios
```

### 2. Configure Privy

```swift
import Privy

let privy = Privy(appId: "your-app-id")
```

### 3. Passkey Association

Add webcredentials to your domain's AASA file for passkey support.

## Authentication Flow

1. User taps "Sign In"
2. Privy passkey signup/login (biometric)
3. Get Privy user DID
4. Connect WebSocket with auth token
5. Create/access embedded Solana wallet

## Key Files

- `ContentView.swift` - Main UI
- `ness_app_iosApp.swift` - App entry point

## Docs

- [Privy Swift Setup](https://docs.privy.io/basics/swift/setup)
- [Passkey Auth](https://docs.privy.io/authentication/user-authentication/login-methods/passkey)
- [Solana Transactions](https://docs.privy.io/wallets/using-wallets/solana/send-a-transaction)
