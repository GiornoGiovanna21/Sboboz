import 'package:flutter/material.dart';

import '../../domain/sboboz_card.dart';

/// A reusable card display widget
class CardWidget extends StatelessWidget {
  const CardWidget({
    required this.card,
    this.size = CardSize.medium,
    super.key,
  });

  final SbobozCard card;
  final CardSize size;

  // A standard playing card is 57.1mm x 88.9mm.
  static const double width = 57.1;

  static const double height = 88.9;

  @override
  Widget build(BuildContext context) {
    final (width, height, fontSize) = switch (size) {
      CardSize.small => (48.0, 64.0, 10.0),
      CardSize.medium => (64.0, 80.0, 12.0),
      CardSize.large => (80.0, 100.0, 14.0),
    };

    final textColor =
        card.suit == SbobozSuit.hearts || card.suit == SbobozSuit.diamonds
            ? Colors.red
            : Colors.black;

    return DefaultTextStyle(
      style: Theme.of(context).textTheme.bodyMedium!.apply(color: textColor),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            '${card.suit.label}\n${card.rank.label}',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    //   return Container(
    //     width: width,
    //     height: height,
    //     decoration: BoxDecoration(
    //       borderRadius: BorderRadius.circular(8),
    //       border: Border.all(
    //         color: Colors.grey,
    //         width: 1,
    //       ),
    //       color: Colors.white,
    //     ),
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         Text(
    //           card.rank.label,
    //           style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
    //         ),
    //         const SizedBox(height: 2),
    //         Text(
    //           card.suit.label,
    //           style: TextStyle(fontSize: fontSize),
    //         ),
    //       ],
    //     ),
    //   );
  }
}

enum CardSize { small, medium, large }
