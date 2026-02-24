# Bloc Party

A cross-platform mobile app that helps neighbors share items and build community — built with Flutter and Firebase.

<table align="center">
  <tr>
    <td>
      <img width="346" height="598"
        alt="CleanShot 2026-02-23 at 17 26 03@2x"
        src="https://github.com/user-attachments/assets/6eff0097-ea81-4682-8f24-b15409e1f87b"
      />
    </td>
    <td>
      <img width="346" height="598"
        alt="CleanShot 2026-02-23 at 17 30 48@2x"
        src="https://github.com/user-attachments/assets/8d8b00e1-25ca-4d6c-9cf6-4defb47995c2"
      />
    </td>
  </tr>
</table>

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

## Team

Built by a team of 5 CS students at the University of Minnesota Duluth.

**Jack Oiend** — CS student at UMD and core contributor to Bloc Party's data and UI layers.

- **Item data layer** — Designed and implemented the `Item` model with full Firestore serialization, including defensive parsing for enums, lists, and edge-case Firestore field types. Built the `ItemViewModel` that drives the live item feed with neighborhood scoping, real-time search, multi-tag filtering, and availability toggling.
- **Home screen** — Architected the home screen's two-column grid layout, image rendering with graceful fallbacks, and the neighborhood selection flow that gates what each user sees.
- **Theme system** — Built a JSON-driven theming system supporting multiple color palettes and dark/light modes, with runtime switching via `ThemeProvider` (`ChangeNotifier`) and persistence through `SharedPreferences`.
- **Item description views** — Implemented the public and private item description screens, including the borrow-request dialog flow that opens a direct chat with the item owner via Firebase Firestore.

Contact: oiendjack@gmail.com

## Privacy Policy

See [PRIVACY_POLICY.md](PRIVACY_POLICY.md) for data collection and usage details.
Contact: oiendjack@gmail.com
