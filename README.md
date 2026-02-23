# Bloc Party

A cross-platform mobile app that helps neighbors share items and build community — built with Flutter and Firebase.

## Overview

Bloc Party lets users within a neighborhood lend and borrow items, schedule events, and communicate with each other in real time. The goal is to reduce waste and strengthen local community by making it easy to share what you have with the people around you.

## Features

- **Item Sharing** — Post items available for lending with photos, descriptions, portability tags, and availability status
- **Neighborhood Scoping** — Users join a neighborhood (via Google Maps address lookup) and only see items from their neighbors
- **Real-Time Messaging** — Direct and group chat between neighbors powered by Firebase Firestore
- **Event Scheduling** — Shared neighborhood calendar for coordinating pickups and community events
- **Authentication Flow** — Email/password sign-up with email verification, profile creation, and persistent sessions
- **Push Notifications** — Firebase Cloud Messaging for new messages and item updates
- **Dark/Light Theme** — Dynamic theme switching loaded from JSON asset files

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3 (Dart) |
| Backend & Database | Firebase (Firestore, Storage, Auth, Cloud Messaging) |
| Navigation | GoRouter with Firebase Auth stream guard |
| State Management | Provider (`ChangeNotifier`) |
| Maps & Location | Google Maps Flutter + Places Autocomplete |
| Calendar | Syncfusion Flutter Calendar |

## Architecture

The app follows an MVC-like structure with a clear separation between data models, views, and navigation logic.

```
lib/
├── flutter_backend/    # Firebase init, GoRouter setup
├── model/              # Data models + business logic (one file per feature)
└── view/               # Screens and widgets (one file per screen)
    ├── login_views/
    ├── chat_view/
    ├── navigation/
    └── widgets/
```

- **Models** own Firestore serialization and business logic. The `Item` model supports defensive parsing for all Firestore fields.
- **GoRouter** listens to `FirebaseAuth` state via `GoRouterRefreshStream` to automatically redirect users on login/logout.
- **Provider** manages theme state globally via `ThemeProvider`.

## Getting Started

**Prerequisites:** Flutter SDK, Firebase CLI, a Firebase project with Firestore/Auth/Storage enabled.

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run tests
flutter test

# Static analysis
flutter analyze
```

## Testing

Unit tests cover core model logic and business rules. Integration tests cover key user flows.

```bash
flutter test                          # all unit tests
flutter test test/item_model_test.dart  # single file
flutter test integration_test/app_test.dart  # integration tests
```

## Privacy Policy

See [PRIVACY_POLICY.md](PRIVACY_POLICY.md) for data collection and usage details.
Contact: oien0034@d.umn.edu
