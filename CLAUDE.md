# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite (better-sqlite3 or Turso). Paste this into your repo root. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default. No API route boilerplate for data fetching. |
| Runtime | Node.js 20+ | `crypto.randomUUID`, native `fetch`, stable `AsyncLocalStorage`. |
| Database | better-sqlite3 (local) or Turso (hosted) | Synchronous SQLite is simpler for reads; Turso for production scale. |
| Schema Migrations | `drizzle-kit` or hand-rolled SQL | Drizzle for type safety; raw SQL when you need zero abstraction overhead. |
| ORM/Query Builder | Drizzle ORM | Zero-runtime types; SQL-like syntax; no magic N+1 problems. |
| Auth | Lucia (or custom session cookies) | No vendor lock-in. Sessions stored in SQLite. |
| Styling | Tailwind CSS + shadcn/ui | Copy-paste components; no phantom dependency updates. |
| Validation | Zod | Same schemas on server and client. |
| Testing | Vitest + Playwright | Unit for logic, E2E for critical paths. |

**Non-negotiable:** We do not use Prisma. It bundles a query engine binary, adds 200ms+ to cold starts, and hides SQL you need to understand for SQLite performance.

---

## Folder Structure

