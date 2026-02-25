import 'package:flutter/material.dart';

import '../../domain/sboboz_card.dart';

/// A selectable chip widget for cards with visual feedback
class CardChipWidget extends StatelessWidget {
  const CardChipWidget({
    required this.card,
    required this.selected,
    this.playable = false,
    this.onTap,
    super.key,
  });

  final SbobozCard card;
  final bool selected;
  final bool playable;
  final VoidCallback? onTap;

  // A standard playing card is 57.1mm x 88.9mm.
  static const double width = 57.1;

  static const double height = 88.9;

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor;
    if (selected) {
      backgroundColor = Theme.of(context).colorScheme.primaryContainer;
    } else if (playable) {
      backgroundColor = Theme.of(context).colorScheme.secondaryContainer;
    }

    final textColor =
        card.suit == SbobozSuit.hearts || card.suit == SbobozSuit.diamonds
            ? Colors.red
            : Colors.black;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            '${card.suit.label}\n${card.rank.label}',
            textAlign: TextAlign.center,
            style:
                Theme.of(context).textTheme.bodyMedium!.apply(color: textColor),
          ),
        ),
      ),
    );
  }
}
