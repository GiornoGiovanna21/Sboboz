// app/lib/features/game/presentation/widgets/multiplayer_overlay.dart
// Purpose: Displays all opponent players positioned around the current player.

import 'package:flutter/material.dart';

import '../../domain/sboboz_game_state.dart';
import '../../domain/sboboz_player.dart';
import '../utils/player_positioning.dart';
import 'opponent_player_card.dart';

class MultiplayerOverlay extends StatelessWidget {
  const MultiplayerOverlay({
    required this.players,
    required this.currentPlayerIndex,
    required this.gameState,
    super.key,
  });

  final List<SbobozPlayer> players;
  final int currentPlayerIndex;
  final SbobozGameState gameState;

  @override
  Widget build(BuildContext context) {
    if (players.length <= 1) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = Size(constraints.maxWidth, constraints.maxHeight);
        final positions = PlayerPositioningUtil.calculatePositions(
            players.length, screenSize);
        final cardSize =
            PlayerPositioningUtil.getPlayerCardSize(players.length);

        return Stack(
          children: List.generate(
            players.length,
            (index) {
              if (index == currentPlayerIndex) {
                return const SizedBox.shrink();
              }

              final player = players[index];
              final position = positions[index];
              final isCurrentTurn = index == currentPlayerIndex;

              return Positioned(
                left: position.offset.dx - cardSize.width / 2,
                top: position.offset.dy - cardSize.height / 2,
                child: OpponentPlayerCard(
                  player: player,
                  isCurrentTurn: isCurrentTurn,
                  turnNumber: gameState.turnNumber.toString(),
                  cardSize: cardSize,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
