// app/lib/core/network/socket_provider.dart
// Purpose: Single socket instance and connection state for the app.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'socket_client.dart';
import 'socket_connection_state.dart';

/// Single Socket.io instance. Created when first read; disposed when provider is disposed.
///
/// Reading this provider (e.g. from LobbyPage) creates the socket and starts connection.
final socketProvider = Provider<io.Socket>((ref) {
  final socket = createSocket();
  ref.onDispose(() => socket.dispose());
  return socket;
});

/// Current connection state. Use in UI to show "Connecting...", "Connected", or error.
final socketConnectionStateProvider =
    StateNotifierProvider<SocketConnectionStateNotifier, SocketConnectionState>(
        (ref) {
  final socket = ref.watch(socketProvider);
  return SocketConnectionStateNotifier(socket);
});

class SocketConnectionStateNotifier extends StateNotifier<SocketConnectionState> {
  SocketConnectionStateNotifier(io.Socket socket)
      : super(const SocketConnecting()) {
    socket.onConnect((_) => state = const SocketConnected());
    socket.onDisconnect((_) => state = const SocketDisconnected());
    socket.onConnectError((data) => state = SocketConnectionError(data.toString()));
  }
}
