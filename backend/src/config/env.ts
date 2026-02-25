// backend/src/config/env.ts
// Purpose: Centralized environment config with validation

import dotenv from 'dotenv';

dotenv.config();

const PORT = parseInt(process.env.PORT ?? '3000', 10);
const NODE_ENV = process.env.NODE_ENV ?? 'development';

export const env = {
  PORT: Number.isNaN(PORT) ? 3000 : PORT,
  NODE_ENV,
  isDev: NODE_ENV === 'development',
  isProd: NODE_ENV === 'production',
} as const;
