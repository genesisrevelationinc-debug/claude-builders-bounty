# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code.  
> Paste this at repo root. Claude reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, stable since 15.1 |
| Runtime | Node.js 20+ | `next start` requires 18+; 20 has native `fetch` stability |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Drizzle ORM | Type-safe SQL, migrations in `.sql`, no hidden queries |
| Auth | Lucia (or custom session) | Session cookies, no JWT in localStorage (XSS-resistant) |
| Styling | Tailwind CSS + CSS Variables | No CSS-in-JS runtime cost; works with RSC |
| Forms | Server Actions + `react-hook-form` | Progressive enhancement, no API route boilerplate |
| Validation | Zod | Same schemas on server and client |
| Testing | Vitest + Playwright | Unit + E2E; no Jest (slower, more config) |

**Non-negotiable:** We do NOT use `turso` or any remote SQLite. This template targets single-node deploys (VPS, Fly, Railway). If you need multi-node, switch to Postgres first—don't fight SQLite's concurrency model.

---

## Folder Structure

