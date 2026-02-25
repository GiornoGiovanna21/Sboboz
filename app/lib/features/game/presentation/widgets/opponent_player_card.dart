// app/lib/features/game/presentation/widgets/opponent_player_card.dart
// Purpose: Displays opponent player info in the multiplayer view.

import 'package:flutter/material.dart';

import '../../domain/sboboz_player.dart';

class OpponentPlayerCard extends StatelessWidget {
  const OpponentPlayerCard({
    required this.player,
    required this.isCurrentTurn,
    required this.turnNumber,
    required this.cardSize,
    super.key,
  });

  final SbobozPlayer player;
  final bool isCurrentTurn;
  final String turnNumber;
  final Size cardSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: cardSize.width,
      height: cardSize.height,
      decoration: BoxDecoration(
        border: Border.all(
          color: isCurrentTurn ? Colors.amber : Colors.grey.shade400,
          width: isCurrentTurn ? 3 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isCurrentTurn ? Colors.amber.shade50 : Colors.white,
        boxShadow: [
          if (isCurrentTurn)
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.5),
              blurRadius: 8,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Player name and status
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isCurrentTurn ? Colors.amber.shade900 : Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isCurrentTurn)
                  Text(
                    'Turn $turnNumber',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.amber.shade700,
                    ),
                  ),
              ],
            ),

            // Card counts
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                  label: 'Hand:',
                  value: '${player.hand.length}',
                  theme: theme,
                ),
                _InfoRow(
                  label: 'Face-down:',
                  value: '${player.faceDown.length}',
                  theme: theme,
                ),
                _InfoRow(
                  label: 'Face-up:',
                  value: '${player.faceUp.whereType<dynamic>().length}',
                  theme: theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.theme,
  });

  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
