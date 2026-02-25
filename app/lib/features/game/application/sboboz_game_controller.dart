// app/lib/features/game/application/sboboz_game_controller.dart
// Purpose: Riverpod StateNotifier managing a local Sboboz game (setup + base loop).

import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/sboboz_card.dart';
import '../domain/sboboz_game_state.dart';
import '../domain/sboboz_player.dart';

/// Top-level provider for a local Sboboz game.
final sbobozGameProvider =
    StateNotifierProvider<SbobozGameController, SbobozGameState>(
  (ref) => SbobozGameController()..startLocalSinglePlayer(),
);

enum Position {
  hand,
  faceUp,
  faceDown,
}

class SbobozGameController extends StateNotifier<SbobozGameState> {
  SbobozGameController() : super(SbobozGameState.empty());

  bool isLowerDecided = false;
  bool isWithEffect = false;

  List<SbobozCard> createDeck() {
    final random = Random();
    final deck = buildSbobozDeck(doubleDeck: true, includeExtraJollies: false);
    shuffleCards(deck, random: random);
    return deck;
  }

  /// Starts a fresh local single-player game.
  /// Deal:
  /// - 10 cards in hand
  /// - 5 face-down table cards
  /// - Player then chooses 5 face-up cards from their hand before play starts.
  void startLocalSinglePlayer() {
    final List<SbobozCard> deck = createDeck();

    final hand = deck.sublist(0, 10);
    final faceDown = deck.sublist(10, 15);
    final remaining = deck.sublist(15);

    final player = SbobozPlayer(
      id: 'local',
      name: 'You',
      hand: hand,
      faceDown: faceDown,
      faceUp: List<SbobozCard?>.filled(5, null),
    );

    state = SbobozGameState(
      players: [player],
      currentPlayerIndex: 0,
      drawPile: remaining,
      playingPile: const [],
      sbobozPile: const [],
      superSbobozPile: const [],
      phase: SbobozGamePhase.choosingFaceUp,
    );
  }

  /// Starts a local multiplayer game with the specified number of players.
  /// Each player receives:
  /// - 10 cards in hand
  /// - 5 face-down table cards
  /// Players then take turns choosing 5 face-up cards from their hand before play starts.
  /// Supports 2–4 players. For more than 4, the deck and dealing logic would need to be adjusted.
  /// For simplicity, all players are controlled locally in this setup. Future enhancements could allow for AI or networked opponents.
  void startLocalMultiplayer(int numPlayers) {
    final List<SbobozCard> deck = createDeck();

    final players = List.generate(numPlayers, (index) {
      final hand = deck.sublist(index * 15, index * 15 + 10);
      final faceDown = deck.sublist(index * 15 + 10, index * 15 + 15);

      return SbobozPlayer(
        id: 'player_$index',
        name: 'Player ${index + 1}',
        hand: hand,
        faceDown: faceDown,
        faceUp: List<SbobozCard?>.filled(5, null),
      );
    });

    final remaining = deck.sublist(numPlayers * 15);

    state = SbobozGameState(
      players: players,
      currentPlayerIndex: 0,
      drawPile: remaining,
      playingPile: const [],
      sbobozPile: const [],
      superSbobozPile: const [],
      phase: SbobozGamePhase.choosingFaceUp,
    );
  }

  /// Advances to the next player's turn.
  /// Handles:
  /// - Circular player order
  /// - Round number increments (when all players have gone)
  /// - Win condition checks
  /// - Calls startTurn() for the new current player
  void nextTurn() {
    // Check if anyone has won before advancing
    final winner = checkWinCondition();
    if (winner != null) {
      state = state.copyWith(phase: SbobozGamePhase.finished);
      return;
    }

    // Calculate next player index
    int nextPlayerIndex = state.currentPlayerIndex + 1;
    int nextRound = state.roundNumber;

    if (nextPlayerIndex >= state.players.length) {
      nextPlayerIndex = 0;
      nextRound++;
    }

    // Update state with new player and turn counters
    state = state.copyWith(
      currentPlayerIndex: nextPlayerIndex,
      turnNumber: state.turnNumber + 1,
      roundNumber: nextRound,
    );

    // Call startTurn for the new player
    startTurn();
  }

  /// Starts a player's turn by checking if they have any playable cards.
  /// If not, automatically picks up the discard pile.
  void startTurn() {
    if (state.phase != SbobozGamePhase.playing) return;

    // Check if current player has no playable cards
    if (!hasPlayableCard && state.playingPile.isNotEmpty) {
      pickUpPile();
    }
  }

// ========== GAME SETUP METHODS ==========
  /// Assigns a card from the current player's hand to one of the five face-up slots.
  ///
  /// - [slotIndex] must be 0–4.
  /// - [handIndex] refers to the index in the current hand at call time.
  void chooseFaceUpCard({required int slotIndex, required int handIndex}) {
    final current = state.currentPlayer;
    if (slotIndex < 0 || slotIndex >= current.faceUp.length) return;
    if (handIndex < 0 || handIndex >= current.hand.length) return;

    final updatedHand = List<SbobozCard>.from(current.hand);
    final card = updatedHand.removeAt(handIndex);

    final updatedFaceUp = List<SbobozCard?>.from(current.faceUp);
    if (updatedFaceUp[slotIndex] != null) {
      SbobozCard? buff = updatedFaceUp[slotIndex];
      updatedFaceUp[slotIndex] = card;
      updatedHand.add(buff!);
    }
    updatedFaceUp[slotIndex] = card;

    final updatedPlayer = current.copyWith(
      hand: updatedHand,
      faceUp: updatedFaceUp,
    );

    final players = List<SbobozPlayer>.from(state.players);
    players[state.currentPlayerIndex] = updatedPlayer;

    state = state.copyWith(players: players);
  }

// Confirms that the current player is done choosing face-up cards and is ready to start playing.
// Every player must call this before the game can transition to the playing phase. In a multiplayer game, this allows each player to choose their face-up cards at their own pace before starting.
  void confirmPicks() {
    final current = state.currentPlayer;
    current.picksConfirm = true;

    // Update the current player in the players list
    final players = List<SbobozPlayer>.from(state.players);
    players[state.currentPlayerIndex] = current;

    // Check if all players are ready
    bool allReady = players.every((p) => p.isReadyForPlay);

    final nextPhase =
        allReady ? SbobozGamePhase.playing : SbobozGamePhase.choosingFaceUp;

    state = state.copyWith(
      players: players,
      phase: nextPhase,
    );

    // If all players are ready, start the first turn
    if (allReady) {
      startTurn();
    }
  }

// ========== GAMEPLAY METHODS ==========

  /// Plays one or more cards of the same rank from the player's hand to the discard pile.
  ///
  /// - All cards in [handIndices] must be of the same rank
  /// - The cards must be playable according to [isCardPlayable]
  /// - After playing, draws cards to maintain 5 cards in hand
  ///
  /// Returns CardPlayOutcome indicating success and whether turn should advance.
  CardPlayOutcome playCards(List<int> handIndices) {
    if (handIndices.isEmpty) return CardPlayOutcome.failed;
    if (state.phase != SbobozGamePhase.playing) return CardPlayOutcome.failed;

    final current = state.currentPlayer;

    // Validate all indices are in range
    for (final index in handIndices) {
      if (index < 0 || index >= current.hand.length) {
        return CardPlayOutcome.failed;
      }
    }

    // Get the cards and verify they're all the same rank
    final cardsToPlay = handIndices.map((i) => current.hand[i]).toList();
    final firstRank = cardsToPlay.first.rank;
    if (!cardsToPlay.every((card) => card.rank == firstRank)) {
      return CardPlayOutcome.failed; // All cards must be the same rank
    }

    // Check if at least one card is playable
    if (!isCardPlayable(cardsToPlay.first, Position.hand)) {
      return CardPlayOutcome.failed;
    }

    // Remove cards from hand (sort indices in descending order to remove safely)
    final updatedHand = List<SbobozCard>.from(current.hand);
    final sortedIndices = List<int>.from(handIndices)
      ..sort((a, b) => b.compareTo(a));
    for (final index in sortedIndices) {
      updatedHand.removeAt(index);
    }

    // Add cards to discard pile
    // final updatedPlayingPile = List<SbobozCard>.from(state.playingPile)
    //   ..addAll(cardsToPlay);

    CardPlayOutcome outcome = checkForEffects(cardsToPlay, Position.hand);

    // Update player with new hand
    final updatedPlayer = current.copyWith(hand: updatedHand);
    final players = List<SbobozPlayer>.from(state.players);
    players[state.currentPlayerIndex] = updatedPlayer;

    // Only update piles that were modified
    var newState = state.copyWith(
      players: players,
      //playingPile: updatedPlayingPile,
    );

    state = newState;

    // Draw cards to maintain 5 in hand (only if hand is not empty)
    if (state.drawPile.isNotEmpty &&
        outcome != CardPlayOutcome.fivePlayedNeedDiscard &&
        outcome != CardPlayOutcome.jackPlayedNeedDraw) {
      _drawToHandSize();
    }

    return outcome;
  }

  /// Plays a single card from the table face-up when hand is empty
  ///
  /// Returns CardPlayOutcome indicating success and whether turn should advance.
  CardPlayOutcome playFaceUpCard(SbobozCard card) {
    if (state.phase != SbobozGamePhase.playing) return CardPlayOutcome.failed;

    final current = state.currentPlayer;

    // Can only play table cards if hand is empty
    if (current.hand.isNotEmpty) return CardPlayOutcome.failed;

    // Check if card is playable
    if (!isCardPlayable(card, Position.faceUp)) return CardPlayOutcome.failed;

    // Find and remove the card from table
    final updatedFaceUp = List<SbobozCard?>.from(current.faceUp);
    final updatedFaceDown = List<SbobozCard?>.from(current.faceDown);

    final index = updatedFaceUp.indexOf(card);
    if (index == -1) return CardPlayOutcome.failed;
    updatedFaceUp[index] = null;
    if (card.rank == SbobozRank.four && updatedFaceDown[index] != null) {
      // Reveal the face-down card under the played 4.
      updatedFaceUp[index] = updatedFaceDown[index];
      updatedFaceDown[index] = null;
    }

    // Add card to discard pile
    // final updatedPlayingPile = List<SbobozCard>.from(state.playingPile)
    //   ..add(card);

    CardPlayOutcome outcome = checkForEffects([card], Position.faceUp);

    // Update player with new table
    final updatedPlayer = current.copyWith(
      faceUp: updatedFaceUp,
      faceDown: updatedFaceDown,
    );
    final players = List<SbobozPlayer>.from(state.players);
    players[state.currentPlayerIndex] = updatedPlayer;

    // Only update piles that were modified
    var newState = state.copyWith(
      players: players,
      //playingPile: updatedPlayingPile,
    );

    state = newState;

    return outcome;
  }

  // This takes the card blindly selected by the Player from their face-down slots and attempts to play it, without knowing what the card is until after the play attempt.
  // This mimics the real-life mechanic of playing a face-down card.
  CardPlayOutcome playHiddenCard(SbobozCard card) {
    if (state.phase != SbobozGamePhase.playing) return CardPlayOutcome.failed;

    final current = state.currentPlayer;

    CardPlayOutcome outcome = CardPlayOutcome.failed;

    // Can only play table cards if hand is empty
    if (current.hand.isNotEmpty) return outcome;
    if (current.faceDown.every((c) => c == null)) {
      return outcome;
    }

    // The rest of the logic is the same as playing a face-up card, except we also need to remove the card from the face-down pile.
    final updatedFaceDown = List<SbobozCard?>.from(current.faceDown);
    final index = updatedFaceDown.indexOf(card);
    if (index == -1) return CardPlayOutcome.failed;
    updatedFaceDown[index] = null;

    // Check if card is playable
    if (!isCardPlayable(card, Position.faceDown)) {
      // Pick up the whole pile as a penalty for playing an unplayable card
      print(
          'Played card $card is not playable. Player must pick up the pile as a penalty.');
      pickUpPile();
      current.hand.add(card);
      outcome = CardPlayOutcome.failed;
    } else {
      // Card is playable, but we need to check if it's a queen and if so apply the effect of skipping the player turn
      if (card.rank == SbobozRank.queen) {
        current.hand.add(card); // Add the queen back to the player's hand
        outcome = CardPlayOutcome.queenPlayedSkipNext;
      } else {
        // Card is playable, proceed as normal
        outcome = checkForEffects([card], Position.faceDown);
      }
    }

    // Update player with new table
    final updatedPlayer = current.copyWith(
      faceDown: updatedFaceDown,
      hand: current.hand,
    );
    final players = List<SbobozPlayer>.from(state.players);
    players[state.currentPlayerIndex] = updatedPlayer;

    // Only update piles that were modified
    var newState = state.copyWith(
      players: players,
    );

    state = newState;

    return outcome;
  }

  /// Handles playing a 5 card: player must select and discard one card from hand to SuperSbobozPile.
  ///
  /// Returns true if successful, false if the hand is empty or card is invalid.
  bool discardCardToSuperPile(int handIndex) {
    if (state.phase != SbobozGamePhase.playing) return false;

    final current = state.currentPlayer;
    if (handIndex < 0 || handIndex >= current.hand.length) return false;

    // Remove card from hand
    final updatedHand = List<SbobozCard>.from(current.hand);
    final discardedCard = updatedHand.removeAt(handIndex);

    // Add to super sboboz pile
    final updatedSuperSbobozPile = List<SbobozCard>.from(state.superSbobozPile)
      ..add(discardedCard);

    // Update player
    final updatedPlayer = current.copyWith(hand: updatedHand);
    final players = List<SbobozPlayer>.from(state.players);
    players[state.currentPlayerIndex] = updatedPlayer;

    state = state.copyWith(
      players: players,
      superSbobozPile: updatedSuperSbobozPile,
    );

    // Draw a card to maintain 5 in hand
    _drawToHandSize();

    // After discarding, the player must end their turn
    nextTurn();

    return true;
  }

  /// Handles playing a Jack: player draws one card from SuperSbobozPile.
  ///
  /// [cardIndex] is the index of the card in the super pile to draw.
  /// Returns true if successful, false if the super pile is empty.
  bool drawFromSuperPile(int cardIndex) {
    if (state.phase != SbobozGamePhase.playing) return false;
    if (state.superSbobozPile.isEmpty) {
      nextTurn();
      return false;
    }
    if (cardIndex < 0 || cardIndex >= state.superSbobozPile.length) {
      return false; // Invalid index
    }

    final current = state.currentPlayer;
    final updatedSuperSbobozPile = List<SbobozCard>.from(state.superSbobozPile);
    final drawnCard = updatedSuperSbobozPile.removeAt(cardIndex);

    final updatedHand = List<SbobozCard>.from(current.hand)..add(drawnCard);

    final updatedPlayer = current.copyWith(hand: updatedHand);
    final players = List<SbobozPlayer>.from(state.players);
    players[state.currentPlayerIndex] = updatedPlayer;

    state = state.copyWith(
      players: players,
      superSbobozPile: updatedSuperSbobozPile,
    );

    // Used when more than 1 J was played
    _drawToHandSize();

    // After drawing, the player must end their turn
    nextTurn();

    return true;
  }

  // Allows a player to pick up the entire discard pile or called automatically when no card is playable.
  void pickUpPile() {
    if (state.phase != SbobozGamePhase.playing) return;
    if (state.playingPile.isEmpty) return;

    final currentP = state.currentPlayer;
    final updatedHand = List<SbobozCard>.from(currentP.hand)
      ..addAll(state.playingPile);

    final updatedPlayer = currentP.copyWith(hand: updatedHand);

    final players = List<SbobozPlayer>.from(state.players);
    players[state.currentPlayerIndex] = updatedPlayer;

    state = state.copyWith(
      players: players,
      playingPile: const [],
    );
  }

// ========== UTILS for GAME LOGIC ==========

  /// Returns the top card of the playing pile, or null if empty.
  SbobozCard? get topOfPile {
    if (state.playingPile.isEmpty) return null;
    return state.playingPile.last;
  }

  void setEightDirection({required bool isLower}) {
    isLowerDecided = isLower;
  }

  void setNineWithEffect({required bool withEffect}) {
    isWithEffect = withEffect;
  }

  /// Checks if the given card can be played on top of the current discard pile according to game rules.
  /// The [position] parameter indicates whether the card is from hand, face-up, or face-down, which can affect playability (e.g. 5s can only be played from hand).
  /// This method does not check for special effects that may occur after playing, only whether the card is legally playable at the moment.
  ///
  /// Rules:
  /// - If discard pile is empty, any card can be played
  /// - 2's and Jolly's can be played on anything (wild)
  /// - If top card is an 8, the suit direction must be followed (not implemented here)
  /// - If top card is a 9, the with or without effect decision must be followed (not implemented here)
  /// - For all other cards, the rank must be equal or higher than the top card's rank
  /// - 5's can only be played from hand
  CardPlayOutcome checkForEffects(List<SbobozCard> cards, Position position) {
    // Check for special effects
    List<SbobozCard>? updatedSbobozPile;
    List<SbobozCard>? updatedSuperSbobozPile;
    List<SbobozCard> updatedPlayingPile =
        List<SbobozCard>.from(state.playingPile)..addAll(cards);
    CardPlayOutcome outcome = CardPlayOutcome.success;

    if (topOfPile?.rank == SbobozRank.seven) {
      state = state.copyWith(playingPile: updatedPlayingPile);
      return CardPlayOutcome.success;
    }

    state = state.copyWith(playingPile: updatedPlayingPile);

    SbobozCard card = cards.first;

    if (card.rank == SbobozRank.king || checkForSboboz(cards)) {
      updatedSuperSbobozPile = List<SbobozCard>.from(state.superSbobozPile)
        ..addAll(state.sbobozPile);
      updatedSbobozPile = List<SbobozCard>.from(updatedPlayingPile);
      updatedPlayingPile.clear();
      outcome = card.rank == SbobozRank.king
          ? CardPlayOutcome.kingPlayed
          : CardPlayOutcome.sbobozTriggered;
    } else if (card.rank == SbobozRank.five && position == Position.hand) {
      if (state.currentPlayer.hand.isEmpty) {
        // If the player has no cards in hand so skip the discard
        return CardPlayOutcome.success;
      }
      outcome = CardPlayOutcome.fivePlayedNeedDiscard;
    } else if (card.rank == SbobozRank.jack) {
      if (state.superSbobozPile.isEmpty) {
        // If the super sboboz pile is empty, the player must skip their next turn instead of drawing
        return CardPlayOutcome.success;
      }
      outcome = CardPlayOutcome.jackPlayedNeedDraw;
    } else if (card.rank == SbobozRank.eight) {
      // For 8, we need to decide the direction of play (higher or lower)
      // Reset choice and let the UI prompt the player.
      isLowerDecided = false;
      outcome = CardPlayOutcome.eightPlayedNeedDirection;
    } else if (card.rank == SbobozRank.nine) {
      // For 9, we need to decide if the effect is with or without
      // Reset choice and let the UI prompt the player.
      isWithEffect = false;
      outcome = CardPlayOutcome.ninePlayedNeedWithEffect;
    } else if (card.rank == SbobozRank.three) {
      // Playing a 3 counters the current sboboz effect and puts the sboboz pile back on the playing pile
      counterSbobozEffect();
    }

    if (isLowerDecided || isWithEffect) {
      // If the play of this card caused a direction or with/without effect decision, we need to reset those after the next card is played that isn't an 8 or 9, so we check for that here
      if (card.rank != SbobozRank.eight && card.rank != SbobozRank.nine) {
        isLowerDecided = false;
        isWithEffect = false;
      }
    }

    var newState = state;

    if (updatedSbobozPile != null) {
      newState = newState.copyWith(sbobozPile: updatedSbobozPile);
    }

    if (updatedSuperSbobozPile != null) {
      newState = newState.copyWith(superSbobozPile: updatedSuperSbobozPile);
    }

    state = newState;

    return outcome;
  }

  /// Checks if a card can be played on top of the current discard pile.
  ///
  /// Rules:
  /// - If discard pile is empty, any card can be played
  /// - 2's and Jolly's can be played on anything (wild)
  /// - If top card is an 8, the suit direction must be followed (not implemented here)
  /// - If top card is a 9, the with or without effect decision must be followed (not implemented here)
  /// - For all other cards, the rank must be equal or higher than the top card's rank
  bool isCardPlayable(SbobozCard card, Position stage) {
    final topCard = topOfPile;
    final current = card.rank;

    // Empty pile - any card can be played
    if (topCard == null) return true;

    // Special cards that can be played on anything
    if (current == SbobozRank.two || current == SbobozRank.jolly) {
      return true;
    } // Jolly or 2 Anything played

    if (topCard.rank == SbobozRank.eight) {
      return isLowerDecided
          ? current.value <= topCard.rank.value
          : current.value >= topCard.rank.value;
    }

    if (topCard.rank == SbobozRank.nine) {
      // Se if with or without effect has been decided
      return isWithEffect
          ? current.hasEffect(stage)
          : !current.hasEffect(stage);
    }

    if (current.value >= topCard.rank.value) {
      return true;
    }

    return false;
  }

  /// Returns true if the current player has at least one playable card in their hand.
  bool get hasPlayableCard {
    final current = state.currentPlayer;
    if (current.hand.isNotEmpty) {
      return current.hand.any((card) => isCardPlayable(card, Position.hand));
    } else if (!current.faceUp.every((card) => card == null)) {
      return current.faceUp
          .whereType<SbobozCard>()
          .any((card) => isCardPlayable(card, Position.faceUp));
    } else {
      return true; // If no cards in hand or face-up, the player must play a face-down card, so we consider that they have a "playable" card even though we don't know what it is yet.
    }
  }

  /// Checks if the given cards trigger a Sboboz effect (4 or more of the same rank in the discard pile).
  bool checkForSboboz(List<SbobozCard> played) {
    int totalSum = 0;
    for (var card in state.playingPile.reversed) {
      if (card.rank != played.first.rank) {
        break;
      }
      totalSum++;
    }
    return totalSum >= 4;
  }

  /// Draws cards from the draw pile until the current player has 5 cards in hand.
  ///
  /// If the draw pile runs out, the player keeps whatever they have.
  void _drawToHandSize() {
    final current = state.currentPlayer;
    const targetHandSize = 5;

    if (current.hand.length >= targetHandSize) return;
    if (state.drawPile.isEmpty) return;

    final cardsNeeded = targetHandSize - current.hand.length;
    final cardsToDraw = min(cardsNeeded, state.drawPile.length);

    final updatedDrawPile = List<SbobozCard>.from(state.drawPile);
    final drawnCards = updatedDrawPile.sublist(0, cardsToDraw);
    updatedDrawPile.removeRange(0, cardsToDraw);

    final updatedHand = List<SbobozCard>.from(current.hand)..addAll(drawnCards);

    final updatedPlayer = current.copyWith(hand: updatedHand);
    final players = List<SbobozPlayer>.from(state.players);
    players[state.currentPlayerIndex] = updatedPlayer;

    state = state.copyWith(
      players: players,
      drawPile: updatedDrawPile,
    );
  }

  /// When a 3 is played the current sboboz pile is put back into the playing pile with the 3 on top
  void counterSbobozEffect() {
    if (state.sbobozPile.isEmpty) return;

    final updatedPile = List<SbobozCard>.from(state.playingPile);
    updatedPile.addAll(state.sbobozPile);
    updatedPile.last =
        updatedPile.firstWhere((card) => card.rank == SbobozRank.three);

    state = state.copyWith(
      playingPile: updatedPile,
      sbobozPile: const [],
    );
  }

  /// Checks if any player has won (eliminated all cards).
  ///
  /// Returns the winning player if one exists, null otherwise.
  /// A player wins when they have:
  /// - Empty hand
  /// - Empty face-down pile
  /// - Empty face-up pile
  SbobozPlayer? checkWinCondition() {
    for (final player in state.players) {
      if (player.hand.isEmpty &&
          player.faceDown.isEmpty &&
          player.faceUp.every((card) => card == null)) {
        return player;
      }
    }
    return null;
  }

  bool get isGameActive =>
      state.phase == SbobozGamePhase.choosingFaceUp ||
      state.phase == SbobozGamePhase.playing;

  bool get isGameFinished => state.phase == SbobozGamePhase.finished;

  bool get isChoosingFaceUp => state.phase == SbobozGamePhase.choosingFaceUp;

  // ==== DEBUGGING/TESTING METHODS BELOW ====

  void wipeDrawPile() {
    state = state.copyWith(drawPile: const []);
  }

  void wipeHand() {
    final current = state.currentPlayer;
    final updatedPlayer = current.copyWith(hand: const []);
    final players = List<SbobozPlayer>.from(state.players);
    players[state.currentPlayerIndex] = updatedPlayer;

    state = state.copyWith(players: players);
  }

  void wipePlayingPile() {
    state = state.copyWith(playingPile: const []);
  }

  void wipeSbobozPile() {
    state = state.copyWith(sbobozPile: const []);
  }

  void wipeSuperSbobozPile() {
    state = state.copyWith(superSbobozPile: const []);
  }

  void resetGame() {
    state = SbobozGameState.empty();
  }

  /// Allows a player to manually draw a card (if they can't play).
  ///
  /// Returns true if a card was drawn, false if the draw pile is empty.
  bool drawCard() {
    if (state.phase != SbobozGamePhase.playing) return false;
    if (state.drawPile.isEmpty) return false;

    final current = state.currentPlayer;
    final updatedDrawPile = List<SbobozCard>.from(state.drawPile);
    final drawnCard = updatedDrawPile.removeAt(0);

    final updatedHand = List<SbobozCard>.from(current.hand)..add(drawnCard);

    final updatedPlayer = current.copyWith(hand: updatedHand);
    final players = List<SbobozPlayer>.from(state.players);
    players[state.currentPlayerIndex] = updatedPlayer;

    state = state.copyWith(
      players: players,
      drawPile: updatedDrawPile,
    );

    return true;
  }
}
