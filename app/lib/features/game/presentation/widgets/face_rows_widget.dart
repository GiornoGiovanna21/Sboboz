import 'package:flutter/material.dart';

import '../../application/sboboz_game_controller.dart';
import '../../domain/sboboz_player.dart';
import 'slot_box_widget.dart';

typedef OnTapSlot = void Function(int slotIndex, bool isFaceUp);

/// Displays the face-down and face-up rows of a player's table
class FaceRowsWidget extends StatelessWidget {
  const FaceRowsWidget({
    required this.player,
    required this.controller,
    required this.selectedHandIndex,
    required this.selectedTableIndices,
    this.canPlayFromTable = false,
    this.canPlayHidden = false,
    this.onTapFaceUpSlot,
    this.onTapTableCard,
    super.key,
  });

  final SbobozPlayer player;
  final SbobozGameController controller;
  final int? selectedHandIndex;
  final Map<String, int>
      selectedTableIndices; // 'faceUp' or 'faceDown' -> index
  final bool canPlayFromTable;
  final bool canPlayHidden;
  final void Function(int slotIndex)? onTapFaceUpSlot;
  final OnTapSlot? onTapTableCard;

  @override
  Widget build(BuildContext context) {
    final isChoosingPhase = selectedHandIndex != null ||
        selectedHandIndex == null && onTapFaceUpSlot != null;

    final isGameNotStarted = controller.isChoosingFaceUp;

    return Column(
      children: [
        // Face-down row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < 5; i++)
              SlotBoxWidget(
                label: '↓',
                card: player.faceDown[i],
                faceUp: false,
                enabled: canPlayHidden && !isChoosingPhase,
                playable: canPlayHidden &&
                    !isChoosingPhase &&
                    player.faceDown[i] != null &&
                    controller.isCardPlayable(
                        player.faceDown[i]!, Position.faceDown),
                selected: selectedTableIndices['faceDown'] == i,
                isChoosingPhase: isGameNotStarted,
                onTap: canPlayHidden && !isChoosingPhase
                    ? () => onTapTableCard?.call(i, false)
                    : null,
              ),
          ],
        ),
        const SizedBox(height: 8),
        // Face-up row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < 5; i++)
              SlotBoxWidget(
                label: '↑',
                card: player.faceUp[i],
                faceUp: true,
                enabled: onTapFaceUpSlot != null ||
                    (canPlayFromTable && !canPlayHidden && !isChoosingPhase),
                highlighted: onTapFaceUpSlot != null,
                playable: canPlayFromTable &&
                    !canPlayHidden &&
                    !isChoosingPhase &&
                    player.faceUp[i] != null &&
                    controller.isCardPlayable(
                        player.faceUp[i]!, Position.faceUp),
                selected: selectedTableIndices['faceUp'] == i,
                isChoosingPhase: isGameNotStarted,
                onTap: onTapFaceUpSlot != null
                    ? () => onTapFaceUpSlot!(i)
                    : canPlayFromTable && !canPlayHidden && !isChoosingPhase
                        ? () => onTapTableCard?.call(i, true)
                        : null,
              ),
          ],
        ),
      ],
    );
  }
}
