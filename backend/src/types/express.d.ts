// backend/src/types/express.d.ts
// Purpose: Extend Express Application with Socket.io instance

import { Server as SocketServer } from 'socket.io';

declare global {
  namespace Express {
    interface Application {
      get(name: 'io'): SocketServer;
      set(name: 'io', value: SocketServer): void;
    }
  }
}

export {};
