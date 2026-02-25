// app/lib/features/game/domain/sboboz_game_state.dart
// Purpose: High-level game state for a local Sboboz 104 session.

import 'sboboz_card.dart';
import 'sboboz_player.dart';

/// High-level phase of a Sboboz game.
enum SbobozGamePhase {
  /// Players have been dealt 10 hand cards + 5 face-down.
  /// Each player still needs to choose 5 face-up cards from their hand.
  choosingFaceUp,

  /// Main gameplay loop (draw, play, apply effects).
  playing,

  /// Game is finished; winner is known.
  finished,
}

/// Direction of play (can change with special cards).
enum GameDirection {
  clockwise,
  counterClockwise,
}

/// Result of a card play action indicating whether turn should advance.
enum CardPlayOutcome {
  /// Regular card played - turn should advance
  success,

  /// Play failed - no turn advancement
  failed,

  /// King played - turn should NOT advance (player may play again)
  kingPlayed,

  /// Sboboz triggered (4 same rank in a row) - turn should NOT advance
  sbobozTriggered,

  /// 5 played - turn should NOT advance, player must discard to SuperSbobozPile
  fivePlayedNeedDiscard,

  /// Jack played - turn should NOT advance, player draws from SuperSbobozPile
  jackPlayedNeedDraw,

  // Queen played from Hidden - next player's turn is skipped
  queenPlayedSkipNext,

  /// Eight played - need to decide direction of play (higher or lower)
  eightPlayedNeedDirection,

  /// Nine played - need to decide if effect is with or without
  ninePlayedNeedWithEffect,

  /// Player attempted to play from table - invalid move
  invalidTablePlay,

  /// Player attempted to play a card that is not playable
  invalidCardPlay,

  /// Player attempted to play out of turn
  invalidTurn,

  /// Player attempted to play a card that doesn't match the required rank
}

class SbobozGameState {
  const SbobozGameState({
    required this.players,
    required this.currentPlayerIndex,
    required this.drawPile,
    required this.playingPile,
    required this.sbobozPile,
    required this.superSbobozPile,
    required this.phase,
    this.turnNumber = 0,
    this.roundNumber = 1,
    this.gameDirection = GameDirection.clockwise,
  });

  /// All players in this game (for now: single local player).
  final List<SbobozPlayer> players;

  /// Index into [players] of the active player.
  final int currentPlayerIndex;

  /// Remaining cards to draw.
  final List<SbobozCard> drawPile;

  /// Temporary discard pile (can be recovered by card 3 effects).
  final List<SbobozCard> playingPile;

  /// Temporary discard pile (can be recovered by card 3 effects).
  final List<SbobozCard> sbobozPile;

  /// Permanently eliminated cards (Super Sboboz pile).
  final List<SbobozCard> superSbobozPile;

  final SbobozGamePhase phase;

  /// Overall turn count throughout the game.
  final int turnNumber;

  /// Current round (advances when all players have taken a turn).
  final int roundNumber;

  /// Direction of play (clockwise or counter-clockwise).
  final GameDirection gameDirection;

  SbobozPlayer get currentPlayer => players[currentPlayerIndex];

  SbobozGameState copyWith({
    List<SbobozPlayer>? players,
    int? currentPlayerIndex,
    List<SbobozCard>? drawPile,
    List<SbobozCard>? playingPile,
    List<SbobozCard>? sbobozPile,
    List<SbobozCard>? superSbobozPile,
    SbobozGamePhase? phase,
    int? turnNumber,
    int? roundNumber,
    GameDirection? gameDirection,
  }) {
    return SbobozGameState(
      players: players ?? this.players,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      drawPile: drawPile ?? this.drawPile,
      playingPile: playingPile ?? this.playingPile,
      sbobozPile: sbobozPile ?? this.sbobozPile,
      superSbobozPile: superSbobozPile ?? this.superSbobozPile,
      phase: phase ?? this.phase,
      turnNumber: turnNumber ?? this.turnNumber,
      roundNumber: roundNumber ?? this.roundNumber,
      gameDirection: gameDirection ?? this.gameDirection,
    );
  }

  /// Convenience factory for a not-yet-started game (no players, no cards).
  factory SbobozGameState.empty() => const SbobozGameState(
        players: [],
        currentPlayerIndex: 0,
        drawPile: [],
        playingPile: [],
        sbobozPile: [],
        superSbobozPile: [],
        phase: SbobozGamePhase.choosingFaceUp,
        turnNumber: 0,
        roundNumber: 1,
        gameDirection: GameDirection.clockwise,
      );
}
