// app/lib/core/network/socket_client.dart
// Purpose: Single place where the Socket.io client is created and configured.

import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config/app_config.dart';

/// Builds the Socket.io client. One instance per app; create via [socketProvider].
///
/// - Uses WebSocket transport only (no polling).
/// - Connects automatically when created ([enableAutoConnect]).
/// - Server must be reachable at [wsBaseUrl] (e.g. http://localhost:3000).
io.Socket createSocket() {
  return io.io(
    wsBaseUrl,
    io.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .build(),
  );
}
