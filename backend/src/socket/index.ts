// backend/src/socket/index.ts
// Purpose: Socket.io server setup and connection handling

import { Server as HttpServer } from 'http';
import { Server, Socket } from 'socket.io';
import { env } from '../config/env';

const SOCKET_PING_INTERVAL = 25000;
const SOCKET_PING_TIMEOUT = 20000;

export function createSocketServer(httpServer: HttpServer): Server {
  const io = new Server(httpServer, {
    cors: { origin: true },
    pingInterval: SOCKET_PING_INTERVAL,
    pingTimeout: SOCKET_PING_TIMEOUT,
  });

  io.on('connection', (socket: Socket) => {
    if (env.isDev) {
      console.log(`[socket] client connected: ${socket.id}`);
    }

    // Echo test for Flutter/client verification (Phase 1)
    socket.on('ping', () => {
      if (env.isDev) console.log('[socket] ping received from', socket.id);
      socket.emit('pong', { serverTime: Date.now() });
    });

    socket.on('disconnect', (reason) => {
      if (env.isDev) {
        console.log(`[socket] client disconnected: ${socket.id}, reason: ${reason}`);
      }
      // TODO: Phase 1 - handle game disconnect (reconnect token, rejoin lobby)
    });
  });

  return io;
}
