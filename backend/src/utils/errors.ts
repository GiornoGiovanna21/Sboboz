// backend/src/utils/errors.ts
// Purpose: Custom error classes for game and API errors

/**
 * Base error for game-related failures (validation, rules, state).
 * Enables consistent handling and optional client-safe messages.
 */
export class GameError extends Error {
  constructor(
    message: string,
    public readonly code?: string,
    public readonly statusCode: number = 400
  ) {
    super(message);
    this.name = 'GameError';
    Object.setPrototypeOf(this, GameError.prototype);
  }
}

/**
 * Used when a request is invalid (bad input, missing params).
 */
export class ValidationError extends GameError {
  constructor(message: string, code?: string) {
    super(message, code ?? 'VALIDATION_ERROR', 422);
    this.name = 'ValidationError';
  }
}
