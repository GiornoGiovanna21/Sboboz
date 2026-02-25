// app/lib/features/game/presentation/utils/player_positioning.dart
// Purpose: Utility for calculating player positions on screen for 2-7 players.

import 'dart:math';

import 'package:flutter/material.dart';

class PlayerPosition {
  PlayerPosition({
    required this.offset,
    required this.alignment,
  });

  /// Position of the player widget on screen
  final Offset offset;

  /// Alignment hint for the player widget
  final Alignment alignment;
}

class PlayerPositioningUtil {
  /// Calculates positions for N players arranged in a circle.
  ///
  /// Returns a list of PlayerPosition objects, one per player.
  /// Player 0 (current) is at the bottom, others arranged clockwise around.
  static List<PlayerPosition> calculatePositions(
    int playerCount,
    Size screenSize,
  ) {
    if (playerCount < 2 || playerCount > 7) {
      throw ArgumentError('Player count must be between 2 and 7');
    }

    final List<PlayerPosition> positions = [];

    // Center of the circle
    final centerX = screenSize.width / 2;
    final centerY = screenSize.height / 2;

    // Radius adjusted based on player count and screen size
    final radius = _getRadiusForPlayerCount(playerCount, screenSize);

    // Start angle (bottom = current player)
    const double startAngle = 270; // Bottom center

    for (int i = 0; i < playerCount; i++) {
      // Calculate angle for this player (clockwise)
      final angle = startAngle + (360 / playerCount * i);
      final radians = angle * (pi / 180);

      // Calculate position using trigonometry
      final x = centerX + radius * cos(radians);
      final y = centerY + radius * sin(radians);

      positions.add(
        PlayerPosition(
          offset: Offset(x, y),
          alignment: _getAlignmentForAngle(angle),
        ),
      );
    }

    return positions;
  }

  /// Returns radius based on player count and screen size.
  static double _getRadiusForPlayerCount(int count, Size screenSize) {
    final minDimension = screenSize.width < screenSize.height
        ? screenSize.width
        : screenSize.height;

    return switch (count) {
      2 => minDimension * 0.3,
      3 => minDimension * 0.35,
      4 => minDimension * 0.35,
      5 => minDimension * 0.38,
      6 => minDimension * 0.4,
      7 => minDimension * 0.38,
      _ => minDimension * 0.35,
    };
  }

  /// Returns alignment based on angle for better widget positioning.
  static Alignment _getAlignmentForAngle(double angle) {
    // Normalize angle to 0-360
    double normalized = angle % 360;
    if (normalized < 0) normalized += 360;

    return switch (normalized.toInt() ~/ 45) {
      0 => Alignment.topCenter,
      1 => Alignment.topRight,
      2 => Alignment.centerRight,
      3 => Alignment.bottomRight,
      4 => Alignment.bottomCenter,
      5 => Alignment.bottomLeft,
      6 => Alignment.centerLeft,
      _ => Alignment.topLeft,
    };
  }

  /// Gets the size for a player card based on player count.
  /// Smaller cards for more players.
  static Size getPlayerCardSize(int playerCount) {
    return switch (playerCount) {
      2 => const Size(160, 120),
      3 => const Size(140, 100),
      4 => const Size(130, 95),
      5 => const Size(120, 90),
      6 => const Size(110, 85),
      7 => const Size(100, 80),
      _ => const Size(130, 95),
    };
  }
}
