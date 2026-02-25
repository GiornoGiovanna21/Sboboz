// app/lib/features/game/domain/sboboz_card.dart
// Purpose: Core card model for Sboboz 104 (suit, rank, deck builder).

import 'dart:math';

import 'package:sboboz_app/features/game/application/sboboz_game_controller.dart';

/// The four standard French suits used in Sboboz.
enum SbobozSuit {
  clubs,
  diamonds,
  hearts,
  spades,
}

extension SbobozSuitX on SbobozSuit {
  String get label {
    switch (this) {
      case SbobozSuit.clubs:
        return '♣';
      case SbobozSuit.diamonds:
        return '♦';
      case SbobozSuit.hearts:
        return '♥';
      case SbobozSuit.spades:
        return '♠';
    }
  }
}

/// All ranks in Sboboz, including Jolly.
///
/// Numeric value mapping (for comparisons):
/// - two = 2, ..., ten = 10
/// - jack = 11, queen = 12, king = 13, ace = 14
/// - jolly is treated specially (wild), lowest priority for comparisons.
enum SbobozRank {
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  ten,
  jack,
  queen,
  king,
  ace,
  jolly,
}

extension SbobozRankX on SbobozRank {
  /// Numerical strength of the rank for ordering/comparisons.
  int get value {
    switch (this) {
      case SbobozRank.two:
        return 2;
      case SbobozRank.three:
        return 3;
      case SbobozRank.four:
        return 4;
      case SbobozRank.five:
        return 5;
      case SbobozRank.six:
        return 6;
      case SbobozRank.seven:
        return 7;
      case SbobozRank.eight:
        return 8;
      case SbobozRank.nine:
        return 9;
      case SbobozRank.ten:
        return 10;
      case SbobozRank.jack:
        return 11;
      case SbobozRank.queen:
        return 12;
      case SbobozRank.king:
        return 13;
      case SbobozRank.ace:
        return 14;
      case SbobozRank.jolly:
        // Treated as the highest when comparing, but then it need to change into choice.
        return 15;
    }
  }

  /// Whether this rank has a special effect in the rules.
  bool hasEffect(Position stage) {
    switch (this) {
      case SbobozRank.three:
      case SbobozRank.five:
      case SbobozRank.seven:
      case SbobozRank.eight:
      case SbobozRank.nine:
      case SbobozRank.jack:
      case SbobozRank.king:
        return true;
      case SbobozRank.six:
      case SbobozRank.ten:
      case SbobozRank.ace:
      case SbobozRank.two:
      case SbobozRank.jolly:
        return false;

      case SbobozRank.four:
        // 4 has a special effect only during the playing phase, not when played face-up during the choosing phase.
        return stage == Position.faceUp;
      case SbobozRank.queen:
        return stage == Position.faceDown;
    }
  }

  /// Short label for UI/debug (e.g. "2", "K", "A", "J*").
  String get label {
    switch (this) {
      case SbobozRank.two:
        return '2';
      case SbobozRank.three:
        return '3';
      case SbobozRank.four:
        return '4';
      case SbobozRank.five:
        return '5';
      case SbobozRank.six:
        return '6';
      case SbobozRank.seven:
        return '7';
      case SbobozRank.eight:
        return '8';
      case SbobozRank.nine:
        return '9';
      case SbobozRank.ten:
        return '10';
      case SbobozRank.jack:
        return 'J';
      case SbobozRank.queen:
        return 'Q';
      case SbobozRank.king:
        return 'K';
      case SbobozRank.ace:
        return 'A';
      case SbobozRank.jolly:
        return 'J*';
    }
  }
}

/// A single Sboboz card.
///
/// For standard cards, [suit] is non-null.
/// For pure jolly cards (if present in the deck), [suit] may be null.
class SbobozCard {
  const SbobozCard({
    required this.rank,
    required this.suit,
  });

  final SbobozRank rank;
  final SbobozSuit suit;

  bool get isJolly => rank == SbobozRank.jolly || rank == SbobozRank.two;

  @override
  String toString() {
    return suit.label + (rank.label);
  }
}

/// Builds a standard Sboboz deck.
///
/// - [doubleDeck] = false → 52 (+ optional jollies)
/// - [doubleDeck] = true  → 104 (+ optional jollies)
/// - [includeExtraJollies] controls whether to add extra dedicated jolly cards.
List<SbobozCard> buildSbobozDeck({
  required bool doubleDeck,
  bool includeExtraJollies = true,
}) {
  final ranks = <SbobozRank>[
    SbobozRank.two,
    SbobozRank.three,
    SbobozRank.four,
    SbobozRank.five,
    SbobozRank.six,
    SbobozRank.seven,
    SbobozRank.eight,
    SbobozRank.nine,
    SbobozRank.ten,
    SbobozRank.jack,
    SbobozRank.queen,
    SbobozRank.king,
    SbobozRank.ace,
  ];

  List<SbobozCard> buildSingleDeck() {
    final result = <SbobozCard>[];
    for (final suit in SbobozSuit.values) {
      for (final rank in ranks) {
        result.add(SbobozCard(rank: rank, suit: suit));
      }
    }
    if (includeExtraJollies) {
      // Two suitless jollies in a single deck by default.
      result.addAll(const [
        SbobozCard(rank: SbobozRank.jolly, suit: SbobozSuit.hearts),
        SbobozCard(rank: SbobozRank.jolly, suit: SbobozSuit.clubs),
      ]);
    }
    return result;
  }

  final deck = <SbobozCard>[];
  deck.addAll(buildSingleDeck());
  if (doubleDeck) {
    deck.addAll(buildSingleDeck());
  }
  return deck;
}

/// Shuffles the given [cards] in-place using [random] (or [Random()] by default).
void shuffleCards(List<SbobozCard> cards, {Random? random}) {
  random ??= Random();
  cards.shuffle(random);
}
