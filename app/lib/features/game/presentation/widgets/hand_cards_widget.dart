import 'package:flutter/material.dart';
import 'package:sboboz_app/features/game/domain/sboboz_card.dart';

import '../../application/sboboz_game_controller.dart';
// import '../../domain/sboboz_card.dart';
import '../../domain/sboboz_player.dart';
import 'card_chip_widget.dart';

/// Displays the player's hand with selection capabilities
class HandCardsWidget extends StatelessWidget {
  const HandCardsWidget({
    required this.player,
    required this.controller,
    required this.selectedIndices,
    required this.isChoosingPhase,
    required this.isPlayingPhase,
    this.selectedHandIndex,
    this.onSelectHandCard,
    this.onDeselectHandCard,
    super.key,
  });

  final SbobozPlayer player;
  final SbobozGameController controller;
  final Set<int> selectedIndices;
  final bool isChoosingPhase;
  final bool isPlayingPhase;
  final int? selectedHandIndex;
  final Function(int)? onSelectHandCard;
  final Function(int)? onDeselectHandCard;

  @override
  Widget build(BuildContext context) {
    // Sort for display, keep original indices for selection and play logic.
    final sortedHand = List<MapEntry<int, SbobozCard>>.generate(
      player.hand.length,
      (index) => MapEntry(index, player.hand[index]),
    )..sort((a, b) {
        final rankCompare = a.value.rank.value.compareTo(b.value.rank.value);
        if (rankCompare != 0) return rankCompare;
        return a.value.suit.index.compareTo(b.value.suit.index);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Your hand (${player.hand.length} cards)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (isChoosingPhase && player.hand.isNotEmpty)
          Text(
            selectedHandIndex == null
                ? 'Tap a hand card, then tap a face-up slot (↑) to place it.'
                : 'Now tap a face-up slot (↑) to place your selected card.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        if (isChoosingPhase && player.hand.isNotEmpty)
          const SizedBox(height: 8),
        if (player.hand.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No cards in hand',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in sortedHand)
                CardChipWidget(
                  card: entry.value,
                  selected: isChoosingPhase
                      ? selectedHandIndex == entry.key
                      : selectedIndices.contains(entry.key),
                  playable: isPlayingPhase
                      ? controller.isCardPlayable(entry.value, Position.hand)
                      : false,
                  onTap: isChoosingPhase
                      ? () {
                          if (selectedHandIndex == entry.key) {
                            onDeselectHandCard?.call(entry.key);
                          } else {
                            onSelectHandCard?.call(entry.key);
                          }
                        }
                      : isPlayingPhase
                          ? () {
                              if (selectedIndices.contains(entry.key)) {
                                onDeselectHandCard?.call(entry.key);
                              } else {
                                onSelectHandCard?.call(entry.key);
                              }
                            }
                          : null,
                ),
            ],
          ),
      ],
    );
  }
}
