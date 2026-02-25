# Sboboz App (Flutter)

Flutter + Riverpod. Connects to Sboboz backend via REST and Socket.io.

## Prerequisites

- Flutter SDK (stable, 3.2+)
- Backend running on `http://localhost:3000` (or set in `lib/core/config/app_config.dart`)

## First-time setup

If the project was scaffolded without Flutter CLI, generate platform folders:

```bash
cd app
flutter create .
```

Then:

```bash
flutter pub get
```

## Run

```bash
cd app
flutter run
```

- **Chrome:** `flutter run -d chrome`
- **Android:** Use `http://10.0.2.2:3000` for API/WS when using Android emulator (change in `app_config.dart`)

## Structure

```
lib/
  core/           # config, network (socket, API), theme
  features/       # home, lobby, game (Phase 1+)
  shared/         # widgets, models (later)
  app.dart
  main.dart
```

## State management

- **Riverpod** for global state (socket, auth, game state).
- Feature-specific providers in `features/<name>/providers/`.
