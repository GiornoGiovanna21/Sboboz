// app/lib/features/game/presentation/local_game_screen.dart
// Purpose: Local Sboboz game screen supporting 2-7 players with turn management.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sboboz_app/features/game/domain/sboboz_card.dart';

import '../../game/application/sboboz_game_controller.dart';
import '../../game/domain/sboboz_game_state.dart';
import 'widgets/widgets.dart';

class LocalGameScreen extends ConsumerStatefulWidget {
  const LocalGameScreen({super.key});

  @override
  ConsumerState<LocalGameScreen> createState() => _LocalGameScreenState();
}

class _LocalGameScreenState extends ConsumerState<LocalGameScreen> {
  int? _selectedHandIndex;
  final Set<int> _selectedCardIndices = {};
  final Map<String, int> _selectedTableIndices =
      {}; // 'faceUp' or 'faceDown' -> index
  bool _showingTurnTransition = false;
  //int? _pendingFiveDiscardIndex; // For 5 card discard action
  CardPlayOutcome? _pendingAction; // Track pending 5 or Jack action

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(sbobozGameProvider);
    final controller = ref.read(sbobozGameProvider.notifier);
    final player = game.currentPlayer;
    final isChoosing = game.phase == SbobozGamePhase.choosingFaceUp;
    final isPlaying = game.phase == SbobozGamePhase.playing;
    final hasHandCards = player.hand.isNotEmpty;
    final hasTableCards = player.faceUp.any((card) => card != null);
    final canPlayFromTable = isPlaying && !hasHandCards;
    final canPlayfromHidden = isPlaying && !hasTableCards;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          game.players.length > 1
              ? 'Sboboz - ${game.players.length} Players (Round ${game.roundNumber})'
              : 'Local Sboboz',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                '${game.currentPlayer.name}\'s Turn',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
        ],
      ),
      // PART OF THE UI WHICH SHOWS OPPONENT INFO, TURN TRANSITION, AND PLAYER CONTROLS
      body: Stack(
        children: [
          // Opponent info at the top (2-player games)
          if (game.players.length == 2)
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Opponent: ${game.players[(game.currentPlayerIndex + 1) % 2].name}',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hand: ${game.players[(game.currentPlayerIndex + 1) % 2].hand.length} | '
                          'Table: ${game.players[(game.currentPlayerIndex + 1) % 2].faceUp.whereType<dynamic>().length} | '
                          'Hidden: ${game.players[(game.currentPlayerIndex + 1) % 2].faceDown.length}',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.grey.shade700,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Turn transition overlay
          if (_showingTurnTransition)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Next Player\'s Turn',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        game
                            .players[
                                (game.currentPlayerIndex) % game.players.length]
                            .name,
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() => _showingTurnTransition = false);
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Ready'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Current player's controls at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GameStatsWidget(
                        game: game,
                        topCard: isPlaying && game.playingPile.isNotEmpty
                            ? controller.topOfPile.toString()
                            : null,
                      ),
                      const Divider(height: 32),
                      Text(
                        'Your table',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      FaceRowsWidget(
                        player: player,
                        controller: controller,
                        selectedHandIndex: _selectedHandIndex,
                        selectedTableIndices: _selectedTableIndices,
                        canPlayFromTable: canPlayFromTable,
                        canPlayHidden: canPlayfromHidden,
                        onTapFaceUpSlot:
                            isChoosing && _selectedHandIndex != null
                                ? (slotIndex) {
                                    controller.chooseFaceUpCard(
                                      slotIndex: slotIndex,
                                      handIndex: _selectedHandIndex!,
                                    );
                                    setState(() => _selectedHandIndex = null);
                                  }
                                : null,
                        onTapTableCard: canPlayFromTable
                            ? (slotIndex, isFaceUp) {
                                setState(() {
                                  if (isFaceUp) {
                                    if (_selectedTableIndices['faceUp'] ==
                                        slotIndex) {
                                      _selectedTableIndices.remove('faceUp');
                                    } else {
                                      _selectedTableIndices['faceUp'] =
                                          slotIndex;
                                      _selectedTableIndices.remove('faceDown');
                                    }
                                  } else {
                                    if (_selectedTableIndices['faceDown'] ==
                                        slotIndex) {
                                      _selectedTableIndices.remove('faceDown');
                                    } else {
                                      _selectedTableIndices['faceDown'] =
                                          slotIndex;
                                      _selectedTableIndices.remove('faceUp');
                                    }
                                  }
                                });
                              }
                            : null,
                      ),
                      const Divider(height: 32),
                      HandCardsWidget(
                        player: player,
                        controller: controller,
                        selectedIndices: _selectedCardIndices,
                        isChoosingPhase: isChoosing,
                        isPlayingPhase: isPlaying,
                        selectedHandIndex: _selectedHandIndex,
                        onSelectHandCard: (index) {
                          setState(() {
                            if (isChoosing) {
                              _selectedHandIndex = index;
                            } else if (isPlaying) {
                              if (_selectedCardIndices.isEmpty) {
                                _selectedCardIndices.add(index);
                              } else {
                                final firstSelectedRank = player
                                    .hand[_selectedCardIndices.first].rank;
                                if (player.hand[index].rank ==
                                    firstSelectedRank) {
                                  _selectedCardIndices.add(index);
                                } else {
                                  _selectedCardIndices.clear();
                                  _selectedCardIndices.add(index);
                                }
                              }
                            }
                          });
                        },
                        onDeselectHandCard: (index) {
                          setState(() {
                            if (isChoosing) {
                              if (_selectedHandIndex == index) {
                                _selectedHandIndex = null;
                              }
                            } else if (isPlaying) {
                              _selectedCardIndices.remove(index);
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      if (isChoosing)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (hasHandCards)
                              TextButton(
                                onPressed: () {
                                  controller.confirmPicks();
                                  // Clear selections for next player
                                  setState(() {
                                    _selectedCardIndices.clear();
                                    _selectedTableIndices.clear();
                                    _selectedHandIndex = null;
                                  });
                                  // Advance to next player and show transition
                                  Future.delayed(
                                      const Duration(milliseconds: 300), () {
                                    controller.nextTurn();
                                    setState(
                                        () => _showingTurnTransition = true);
                                  });
                                },
                                child: const Text('CONFIRM PICKS'),
                              ),
                          ],
                        ),
                      if (isPlaying)
                        GameControlsWidget(
                          selectedCardCount: hasHandCards
                              ? _selectedCardIndices.length
                              : (_selectedTableIndices.isNotEmpty ? 1 : 0),
                          canPlayCards: hasHandCards
                              ? _selectedCardIndices.isNotEmpty
                              : _selectedTableIndices.isNotEmpty,
                          canDrawCard: game.drawPile.isNotEmpty,
                          onPlayCards: () {
                            CardPlayOutcome outcome;
                            if (hasHandCards) {
                              outcome = controller
                                  .playCards(_selectedCardIndices.toList());
                            } else {
                              if (_selectedTableIndices['faceUp'] != null) {
                                final tableCard = player
                                    .faceUp[_selectedTableIndices['faceUp']!];
                                outcome = tableCard != null
                                    ? controller.playFaceUpCard(tableCard)
                                    : CardPlayOutcome.failed;
                              } else if (_selectedTableIndices['faceDown'] !=
                                  null) {
                                final tableCard = player.faceDown[
                                    _selectedTableIndices['faceDown']!];
                                outcome = tableCard != null
                                    ? controller.playHiddenCard(tableCard)
                                    : CardPlayOutcome.failed;
                              } else {
                                outcome = CardPlayOutcome.failed;
                              }
                            }

                            if (outcome != CardPlayOutcome.failed) {
                              setState(() {
                                _selectedCardIndices.clear();
                                _selectedTableIndices.clear();
                              });

                              // Check if we should advance the turn
                              if (outcome == CardPlayOutcome.success) {
                                // Regular card played - advance turn
                                Future.delayed(
                                    const Duration(milliseconds: 300), () {
                                  controller.nextTurn();
                                  setState(() => _showingTurnTransition = true);
                                });
                              } else if (outcome ==
                                  CardPlayOutcome.kingPlayed) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'King played! Pile burned. Play again!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              } else if (outcome ==
                                  CardPlayOutcome.sbobozTriggered) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Sboboz! Pile cleared. Play again!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              } else if (outcome ==
                                  CardPlayOutcome.eightPlayedNeedDirection) {
                                setState(() => _pendingAction = outcome);
                                _showEightDirectionDialog(
                                  context,
                                  controller,
                                );
                              } else if (outcome ==
                                  CardPlayOutcome.ninePlayedNeedWithEffect) {
                                setState(() => _pendingAction = outcome);
                                _showNineEffectDialog(
                                  context,
                                  controller,
                                );
                              } else if (outcome ==
                                  CardPlayOutcome.fivePlayedNeedDiscard) {
                                setState(() => _pendingAction = outcome);
                                _showFiveDiscardDialog(context);
                              } else if (outcome ==
                                  CardPlayOutcome.jackPlayedNeedDraw) {
                                setState(() => _pendingAction = outcome);
                                _showJackDrawDialog(context, controller);
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Cannot play those cards!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          onDrawCard: () {
                            final success = controller.drawCard();
                            if (!success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('No more cards to draw!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          onPickUpPile: () => controller.pickUpPile(),
                          onEndTurn: game.players.length == 2
                              ? () {
                                  // Clear selections for next player
                                  setState(() {
                                    _selectedCardIndices.clear();
                                    _selectedTableIndices.clear();
                                    _selectedHandIndex = null;
                                  });
                                  // Advance to next player and show transition
                                  Future.delayed(
                                      const Duration(milliseconds: 300), () {
                                    controller.nextTurn();
                                    setState(
                                        () => _showingTurnTransition = true);
                                  });
                                }
                              : null,
                        ),
                      TextButton(
                          onPressed: controller.wipeDrawPile,
                          child: const Text('WIPE DRAW PILE (DEBUG)')),
                      TextButton(
                          onPressed: controller.wipePlayingPile,
                          child: const Text('WIPE PLAYING PILE (DEBUG)')),
                      TextButton(
                          onPressed: controller.wipeSbobozPile,
                          child: const Text('WIPE SBOBOZ PILE (DEBUG)')),
                      TextButton(
                          onPressed: controller.wipeSuperSbobozPile,
                          child: const Text('WIPE SUPER SBOBOZ PILE (DEBUG)')),
                      TextButton(
                          onPressed: controller.wipeHand,
                          child: const Text('WIPE HAND (DEBUG)')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFiveDiscardDialog(
    BuildContext context,
  ) {
    final controller = ref.read(sbobozGameProvider.notifier);
    final game = ref.read(sbobozGameProvider);

    if (_pendingAction != CardPlayOutcome.fivePlayedNeedDiscard) return;

    if (_selectedTableIndices['faceUp'] != null ||
        _selectedTableIndices['faceDown'] != null) {
      return;
    }

    if (game.currentPlayer.hand.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => FiveDiscardDialog(
        game: game,
        onDiscard: (index) {
          controller.discardCardToSuperPile(index);
          Navigator.of(dialogContext).pop();
          setState(() {
            _pendingAction = null;
            // _pendingFiveDiscardIndex = null;
          });
        },
      ),
    );
  }

  void _showJackDrawDialog(
    BuildContext context,
    SbobozGameController controller,
  ) {
    final game = ref.read(sbobozGameProvider);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => JackDrawDialog(
        superPile: game.superSbobozPile,
        onDraw: (cardIndex) {
          final success = controller.drawFromSuperPile(cardIndex);
          Navigator.of(dialogContext).pop();
          if (success) {
            setState(() {
              _pendingAction = null;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid card selection!'),
                duration: Duration(seconds: 2),
              ),
            );
            setState(() {
              _pendingAction = null;
            });
          }
        },
      ),
    );
  }

  void _showEightDirectionDialog(
    BuildContext context,
    SbobozGameController controller,
  ) {
    if (_pendingAction != CardPlayOutcome.eightPlayedNeedDirection) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eight Played!'),
        content: const Text(
          'Choose direction for the next card:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.setEightDirection(isLower: false);
              Navigator.of(dialogContext).pop();
              setState(() => _pendingAction = null);
              controller.nextTurn();
              setState(() => _showingTurnTransition = true);
            },
            child: const Text('Higher'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.setEightDirection(isLower: true);
              Navigator.of(dialogContext).pop();
              setState(() => _pendingAction = null);
              controller.nextTurn();
              setState(() => _showingTurnTransition = true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black87,
            ),
            child: const Text('Lower'),
          ),
        ],
      ),
    );
  }

  void _showNineEffectDialog(
    BuildContext context,
    SbobozGameController controller,
  ) {
    if (_pendingAction != CardPlayOutcome.ninePlayedNeedWithEffect) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nine Played!'),
        content: const Text(
          'Choose with or without effect:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.setNineWithEffect(withEffect: false);
              Navigator.of(dialogContext).pop();
              setState(() => _pendingAction = null);
              controller.nextTurn();
              setState(() => _showingTurnTransition = true);
            },
            child: const Text('Without'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.setNineWithEffect(withEffect: true);
              Navigator.of(dialogContext).pop();
              setState(() => _pendingAction = null);
              controller.nextTurn();
              setState(() => _showingTurnTransition = true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black87,
            ),
            child: const Text('With Effect'),
          ),
        ],
      ),
    );
  }
}

/// Dialog for selecting a card to discard to Super Pile when 5 is played
class FiveDiscardDialog extends StatefulWidget {
  const FiveDiscardDialog({
    required this.game,
    required this.onDiscard,
    super.key,
  });

  final SbobozGameState game;
  final Function(int) onDiscard;

  @override
  State<FiveDiscardDialog> createState() => _FiveDiscardDialogState();
}

class _FiveDiscardDialogState extends State<FiveDiscardDialog> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final player = widget.game.currentPlayer;

    return AlertDialog(
      title: const Text('5 Played!'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select one card from your hand to discard to the Super Pile:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: player.hand.length,
                itemBuilder: (context, index) {
                  final card = player.hand[index];
                  final isSelected = selectedIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedIndex = index);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.amber : Colors.grey.shade100,
                        border: Border.all(
                          color:
                              isSelected ? Colors.amber.shade700 : Colors.grey,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${card.suit.label} ${card.rank.toString().split('.').last}',
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : null,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: selectedIndex != null
              ? () {
                  widget.onDiscard(selectedIndex!);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black87,
          ),
          child: const Text('DISCARD'),
        ),
      ],
    );
  }
}

/// Dialog for drawing a card from Super Pile when Jack is played
class JackDrawDialog extends StatefulWidget {
  const JackDrawDialog({
    required this.superPile,
    required this.onDraw,
    super.key,
  });

  final List<SbobozCard> superPile;
  final Function(int) onDraw;

  @override
  State<JackDrawDialog> createState() => _JackDrawDialogState();
}

class _JackDrawDialogState extends State<JackDrawDialog> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    // Group cards by rank to compact display (same rank = same suit doesn't matter)
    final cardsByRank = <dynamic, List<int>>{};
    for (int i = 0; i < widget.superPile.length; i++) {
      final card = widget.superPile[i];
      final key = card.rank;
      (cardsByRank[key] ??= []).add(i);
    }

    return AlertDialog(
      title: const Text('Jack Played!'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select one card from the Super Pile:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: cardsByRank.length,
                itemBuilder: (context, groupIndex) {
                  final entries = cardsByRank.entries.toList();
                  final indices = entries[groupIndex].value;
                  final firstCard = widget.superPile[indices.first];
                  final count = indices.length;
                  final isSelected =
                      selectedIndex != null && indices.contains(selectedIndex);

                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedIndex = indices.first);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.amber : Colors.grey.shade100,
                        border: Border.all(
                          color:
                              isSelected ? Colors.amber.shade700 : Colors.grey,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${firstCard.rank.label}${count > 1 ? ' (x$count)' : ''}',
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : null,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: selectedIndex != null
              ? () => widget.onDraw(selectedIndex!)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black87,
          ),
          child: const Text('DRAW'),
        ),
      ],
    );
  }
}
