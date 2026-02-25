import 'package:flutter/material.dart';

/// Game control buttons for playing, drawing, and managing piles
class GameControlsWidget extends StatelessWidget {
  const GameControlsWidget({
    required this.selectedCardCount,
    required this.canPlayCards,
    required this.canDrawCard,
    required this.onPlayCards,
    required this.onDrawCard,
    required this.onPickUpPile,
    this.onEndTurn,
    super.key,
  });

  final int selectedCardCount;
  final bool canPlayCards;
  final bool canDrawCard;
  final VoidCallback onPlayCards;
  final VoidCallback onDrawCard;
  final VoidCallback onPickUpPile;
  final VoidCallback? onEndTurn;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: canPlayCards ? onPlayCards : null,
              icon: const Icon(Icons.play_arrow),
              label: Text(
                selectedCardCount == 0
                    ? 'Play Cards'
                    : 'Play ${selectedCardCount} Card(s)',
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton.icon(
              onPressed: canDrawCard ? onDrawCard : null,
              icon: const Icon(Icons.file_download),
              label: const Text('Draw Card'),
            ),
            const SizedBox(width: 16),
            TextButton(
              onPressed: onPickUpPile,
              child: const Text('Pick Up Pile'),
            ),
          ],
        ),
        if (onEndTurn != null) ...[
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onEndTurn,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text(
              'END TURN',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ],
    );
  }
}
