// backend/src/app.ts
// Purpose: Express app setup - routes, CORS, error handling

import express, { Request, Response, NextFunction } from 'express';
import cors from 'cors';
import { env } from './config/env';
import { GameError } from './utils/errors';

const app = express();

app.use(cors({ origin: true, credentials: true }));
app.use(express.json());

// Health check for Railway/deployment and local dev
app.get('/health', (_req: Request, res: Response) => {
  res.json({
    ok: true,
    service: 'sboboz-backend',
    env: env.NODE_ENV,
    timestamp: new Date().toISOString(),
  });
});

// API placeholder - Phase 1 will add /api/auth, /api/lobby, etc.
app.get('/api', (_req: Request, res: Response) => {
  res.json({ message: 'Sboboz 104 API', version: '0.1.0' });
});

// 404
app.use((_req: Request, res: Response) => {
  res.status(404).json({ error: 'Not found' });
});

// Error handler - GameError and generic
app.use((err: Error, _req: Request, res: Response, _next: NextFunction) => {
  if (err instanceof GameError) {
    res.status(err.statusCode).json({ error: err.message, code: err.code });
    return;
  }
  console.error(err);
  res.status(500).json({
    error: env.isDev ? err.message : 'Internal server error',
  });
});

export default app;
