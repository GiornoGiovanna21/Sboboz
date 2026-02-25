// app/lib/core/config/app_config.dart
// Purpose: API base URL and app config (env / build flavors later)

/// Backend base URL. Use localhost for emulator, 10.0.2.2 for Android emulator.
const String kApiBaseUrl = 'http://localhost:3000';

/// WebSocket URL for Socket.io (same host as API in dev).
String get wsBaseUrl => kApiBaseUrl;
