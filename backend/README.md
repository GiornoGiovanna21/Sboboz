# Sboboz Backend

Node.js + Express + Socket.io + TypeScript. PostgreSQL/Supabase in Phase 1.

## Setup

```bash
cd backend
npm install
cp .env.example .env
npm run dev
```

- **API:** http://localhost:3000/health  
- **Socket.io:** ws on same origin (e.g. `http://localhost:3000`)

## Scripts

| Command   | Description              |
|----------|--------------------------|
| `npm run dev`  | Run with ts-node-dev (watch) |
| `npm run build`| Compile to `dist/`       |
| `npm start`    | Run compiled `dist/index.js` |
| `npm run lint` | ESLint (when configured)  |
| `npm test`     | Jest (when tests added)  |

## Structure

```
src/
  config/     # env, constants
  routes/     # REST routes (auth, lobby)
  services/   # game logic, validation
  socket/     # Socket.io handlers
  types/      # TS declarations
  utils/      # errors, helpers
  app.ts      # Express app
  index.ts    # Entry point
```
