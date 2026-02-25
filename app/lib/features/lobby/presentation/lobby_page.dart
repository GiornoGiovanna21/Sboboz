// app/lib/features/lobby/presentation/lobby_page.dart
// Purpose: Lobby screen - socket is created here; shows connection status (Phase 1).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sboboz_app/core/network/socket_connection_state.dart';
import 'package:sboboz_app/core/network/socket_provider.dart';

class LobbyPage extends ConsumerWidget {
  const LobbyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(socketConnectionStateProvider);
    final socket = ref.watch(socketProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lobby'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ConnectionStatus(connectionState),
            const SizedBox(height: 32),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                socket.emit('ping');
                socket.on('pong', (data) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Pong: $data')),
                    );
                  }
                });
              },
              icon: const Icon(Icons.wifi_tethering),
              label: const Text('Ping server'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionStatus extends StatelessWidget {
  const _ConnectionStatus(this.state);

  final SocketConnectionState state;

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = switch (state) {
      SocketConnecting() => (Icons.sync, 'Connecting...', Colors.orange),
      SocketConnected() => (Icons.check_circle, 'Connected', Colors.green),
      SocketDisconnected() => (Icons.cloud_off, 'Disconnected', Colors.grey),
      SocketConnectionError(:final message) => (
          Icons.error_outline,
          'Error: $message',
          Colors.red,
        ),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: color, fontSize: 16)),
      ],
    );
  }
}
