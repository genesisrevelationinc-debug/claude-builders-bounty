# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your repo root and Claude will understand your conventions without asking questions.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, built on React 19 |
| Runtime | Node.js 20+ | `next dev --turbo` requires Node 18+, 20 for native `fetch` stability |
| Database | better-sqlite3 | Synchronous, fast, zero-config for single-node deploys. Switch to `@libsql/client` only if you need Turso/edge |
| ORM/Query | Drizzle ORM | Type-safe SQL, migrations via `drizzle-kit`, no hidden queries |
| Auth | Lucia (or custom session) | Session cookies in SQLite, no external auth service dependency |
| Styling | Tailwind CSS 3.4 + shadcn/ui | Utility-first, no runtime CSS, components are copy-paste owned |
| Validation | Zod | Same schemas for API, forms, and DB inserts |
| Testing | Vitest + Playwright | Unit tests run in Node (fast), E2E in real browser |

**Non-negotiable:** We do not use Prisma (heavy, slow startup, migration black box). We do not use MongoDB (schema drift, no joins). We do not use tRPC (unnecessary indirection with Server Actions).

---

## Folder Structure

