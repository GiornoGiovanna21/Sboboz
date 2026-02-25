// backend/src/index.ts
// Purpose: Entry point - starts HTTP server and Socket.io

import http from 'http';
import { env } from './config/env';
import app from './app';
import { createSocketServer } from './socket/index';
import { client } from './config/appwrite';

const server = http.createServer(app);
const io = createSocketServer(server);

// Attach io to app for use in routes if needed (e.g. emit from REST)
app.set('io', io);

// Ping Appwrite backend server to verify setup
client.ping();

server.listen(env.PORT, () => {
  console.log(`Sboboz backend listening on port ${env.PORT} (${env.NODE_ENV})`);
});
