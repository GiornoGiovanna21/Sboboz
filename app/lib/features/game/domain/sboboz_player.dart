// app/lib/features/game/domain/sboboz_player.dart
// Purpose: Per-player card zones for Sboboz (hand, face-down, face-up).

import 'sboboz_card.dart';

class SbobozPlayer {
  SbobozPlayer({
    required this.id,
    required this.name,
    required this.hand,
    required this.faceDown,
    required this.faceUp,
  });

  final String id;
  final String name;

  /// Cards currently in the player's hand.
  final List<SbobozCard> hand;

  /// Five face-down cards on the table.
  final List<SbobozCard?> faceDown;

  /// Five face-up cards, one on top of each face-down slot.
  ///
  /// During the pre-game setup, these will be null until the player chooses
  /// which cards from their hand to place in each slot.
  final List<SbobozCard?> faceUp;

  bool confirmPicks = false;

  /// Whether the player finished choosing their five face-up cards.
  bool get isReadyForPlay =>
      faceUp.length == 5 &&
      faceUp.whereType<SbobozCard>().length == 5 &&
      confirmPicks;

  set picksConfirm(bool confirmation) => confirmPicks = confirmation;

  SbobozPlayer copyWith({
    List<SbobozCard>? hand,
    List<SbobozCard?>? faceDown,
    List<SbobozCard?>? faceUp,
  }) {
    return SbobozPlayer(
      id: id,
      name: name,
      hand: hand ?? this.hand,
      faceDown: faceDown ?? this.faceDown,
      faceUp: faceUp ?? this.faceUp,
    );
  }
}
