# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Run all unit tests
flutter test

# Run a single test file
flutter test test/item_model_test.dart

# Run a specific test by name
flutter test --name "Item constructor works correctly"

# Run integration tests
flutter test integration_test/app_test.dart

# Lint / static analysis
flutter analyze

# Run the app
flutter run

# Clean build artifacts
flutter clean
```

## Architecture

Bloc Party is a Flutter mobile app for neighborhood item-sharing. It follows an MVC-like pattern with Provider for state management.

**Layer breakdown:**

- `lib/flutter_backend/` — Firebase initialization (`firebase_options.dart`) and router setup (`go_router.dart`). The router uses `GoRouterRefreshStream` to listen to `FirebaseAuth` state changes and guard routes.
- `lib/view/navigation/routs.dart` — Defines all GoRouter routes. Auth state determines the initial route (`/auth` vs `/home`).
- `lib/model/` — One model file per feature (e.g. `item_model.dart`, `chat_model.dart`). Models handle Firestore serialization and business logic. `theme_provider.dart` uses `ChangeNotifier` and is the primary Provider in the tree.
- `lib/view/` — One file per screen, grouped by feature (`login_views/`, `chat_view/`, `widgets/`).

**Core data model — `Item`:**
- Has fields: `id`, `name`, `description`, `userId`, `imagePath`, `isAvailable`, `neighborhoodId` (list), `tags` (list), `portability` (enum: portable/semi-portable/immovable).
- `toFirestore()` and `fromFirestore()` methods handle serialization with defensive parsing.

**Firebase services used:** Firestore (data), Storage (images), Auth (email/password), Messaging (push notifications).

**Navigation:** GoRouter with named routes. Auth guard redirects unauthenticated users to `/auth`. Post-login flow: `/auth` → `/verify-email` → `/create-profile` → `/home`.

**Testing:** Unit tests live in `test/`, integration tests in `integration_test/`. Tests use pure Dart (no Flutter test widget setup) for model/logic tests.
