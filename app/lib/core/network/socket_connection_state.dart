// app/lib/core/network/socket_connection_state.dart
// Purpose: UI-facing connection state for the Socket.io client.

/// Represents the current connection state of the socket.
sealed class SocketConnectionState {
  const SocketConnectionState();
}

/// Socket is attempting to connect.
final class SocketConnecting extends SocketConnectionState {
  const SocketConnecting();
}

/// Socket is connected and ready for events.
final class SocketConnected extends SocketConnectionState {
  const SocketConnected();
}

/// Socket disconnected (e.g. server closed or network lost).
final class SocketDisconnected extends SocketConnectionState {
  const SocketDisconnected();
}

/// Connection failed (e.g. server unreachable, invalid URL).
final class SocketConnectionError extends SocketConnectionState {
  const SocketConnectionError(this.message);
  final String message;
}
