# CargoClick 🚢

CargoClick is a dynamic mobile marketplace that connects shippers with available cargo transportation, making maritime logistics efficient, transparent, and effortlessly managed right from your pocket.

## Features

- 🔐 User authentication (Shipper/Carrier roles)
- 📦 Publish freight listings with photos
- 🗺️ Browse available freight in gallery
- 🚚 Manage routes and trips
- 📋 Handle shipping requests
- 🔔 Real-time notifications
- 📱 Mobile-first responsive design
- 🌐 Progressive Web App (PWA) support

## Tech Stack

- **Flutter** - UI framework
- **Firebase Auth** - Authentication
- **Cloud Firestore** - Database
- **Firebase Storage** - Image storage
- **Firebase Hosting** - Web deployment

## Project Structure

```
lib/
├── main.dart           # App entry point
├── theme.dart          # App theming
├── models/            # Data models
│   ├── flete.dart
│   └── usuario.dart
├── screens/           # App screens
│   ├── login_page.dart
│   ├── registro_page.dart
│   ├── home_page.dart
│   ├── publicar_flete_page.dart
│   ├── galeria_fletes_page.dart
│   ├── mis_recorridos_page.dart
│   └── solicitudes_page.dart
├── services/          # Business logic
│   ├── auth_service.dart
│   ├── flete_service.dart
│   ├── photo_service.dart
│   ├── notifications_service.dart
│   └── solicitudes_service.dart
└── widgets/           # Reusable components
    └── flete_card.dart
```

## Getting Started

### Prerequisites

- Flutter SDK 3.6.0 or higher
- Firebase project configured

### Installation

1. Clone the repository
```bash
git clone <your-repo-url>
cd Cargo_click_mockpup
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run -d chrome  # For web
flutter run            # For mobile
```

## Deployment

The app automatically deploys to Firebase Hosting on every push to `main` branch via GitHub Actions.

### Manual Deploy

```bash
flutter build web --release
firebase deploy --only hosting
```

## Environment

- Firebase Project ID: `sellora-2xtskv`
- Hosting URL: Will be provided after first deploy

## License

All rights reserved.
