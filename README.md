# Jupiter Perp Trader

A perpetual futures trading interface built on the Jupiter Protocol.

## Tech Stack

### Frontend
- Flutter/Dart for cross-platform UI
- Secure self-custodial Solana wallet

### Backend
- Go server
- PostgreSQL database
- JWT authentication

## Features

- Trade perpetual futures
- Support for multiple tokens (SOL, ETH, WBTC)
- Real-time market data and position tracking
- Take Profit/Stop Loss order management
- Email-based authentication
- Wallet integration for trade execution

## Getting Started

### Prerequisites
- Flutter
- Go 1.21+
- PostgreSQL
- `.env` file with required configuration

### Running Locally

1. Start the backend:

```bash
cd server
go run cmd/api-server/main.go
```

2. Run the Flutter app:
```bash
cd client
flutter run
```
