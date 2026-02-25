import 'package:flutter/material.dart';

import '../../domain/sboboz_game_state.dart';

/// Displays game statistics and pile information
class GameStatsWidget extends StatelessWidget {
  const GameStatsWidget({
    required this.game,
    required this.topCard,
    super.key,
  });

  final SbobozGameState game;
  final String? topCard;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phase: ${game.phase.name}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text('Draw pile: ${game.drawPile.length} cards'),
        Text('Playing pile: ${game.playingPile.length} cards'),
        Text('Discard pile: ${game.sbobozPile.length} cards'),
        if (topCard != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Top Card',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    topCard!,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
          ),
        Text('Super Sboboz pile: ${game.superSbobozPile.length} cards'),
      ],
    );
  }
}
