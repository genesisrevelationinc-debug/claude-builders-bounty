# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production SaaS built with Next.js 15 App Router and SQLite (better-sqlite3 or Turso). Paste this into your repo root. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, built on React 19 |
| Runtime | Node.js 20+ | Required for `fetch` improvements, native `crypto` |
| Database | better-sqlite3 (local) / Turso (prod) | Same libSQL dialect, sync API, no connection pool hell |
| ORM/Query | Drizzle ORM | Type-safe SQL, zero runtime overhead, migration-friendly |
| Auth | Lucia (or custom session) | Lightweight, works with SQLite, no vendor lock-in |
| Styling | Tailwind CSS 4 | Utility-first, no CSS-in-JS runtime cost |
| Forms | Server Actions + `useFormStatus` | No API routes needed, progressive enhancement free |
| Validation | Zod | Same schemas on server and client, tiny bundle |
| Testing | Vitest + Playwright | Unit + E2E, fast, modern |

**Hard rule:** No other database. If you need Redis, you're caching wrong. Use SQLite's `TEMP` tables or in-memory connections.

---

## Folder Structure

