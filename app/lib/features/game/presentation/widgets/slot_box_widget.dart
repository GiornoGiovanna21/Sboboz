import 'package:flutter/material.dart';

import '../../domain/sboboz_card.dart';

/// A slot box for displaying face-up or face-down cards
class SlotBoxWidget extends StatelessWidget {
  const SlotBoxWidget({
    required this.label,
    required this.card,
    required this.faceUp,
    this.enabled = false,
    this.isChoosingPhase = false,
    this.highlighted = false,
    this.playable = false,
    this.selected = false,
    this.onTap,
    super.key,
  });

  final String label;
  final SbobozCard? card;
  final bool isChoosingPhase;
  final bool faceUp;
  final bool enabled;
  final bool highlighted;
  final bool playable;
  final bool selected;
  final VoidCallback? onTap;
  // A standard playing card is 57.1mm x 88.9mm.
  static const double width = 57.1;

  static const double height = 88.9;

  @override
  Widget build(BuildContext context) {
    final baseBorderColor = faceUp ? Colors.blue : Colors.grey;
    Color borderColor = baseBorderColor;

    if (selected) {
      borderColor = Theme.of(context).colorScheme.primary;
    } else if (highlighted) {
      borderColor = Colors.deepPurple;
    } else if (playable) {
      borderColor = Colors.lightBlueAccent;
    }

    final borderWidth = selected || highlighted || playable ? 2.0 : 1.0;
    final text = card == null ? 'Empty' : card.toString();

    final child = faceUp
        ? card != null || isChoosingPhase
            ? Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(8),
                width: width,
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor, width: borderWidth),
                  color: selected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label),
                    const SizedBox(height: 4),
                    Text(
                      text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              )
            : Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(8),
                width: width,
                height: height,
                decoration: null,
              )
        : card != null
            ? Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(8),
                width: width,
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor, width: borderWidth),
                  image: card != null
                      ? const DecorationImage(
                          image: AssetImage('assets/cards/back.png'),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: Center(
                  child: card != null ? null : Text(label),
                ),
              )
            : Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(8),
                width: width,
                height: height,
                decoration: null,
              );

    if (!enabled || onTap == null) return child;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: child,
    );
  }
}
