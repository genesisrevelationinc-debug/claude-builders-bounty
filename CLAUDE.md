# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite (better-sqlite3 or Turso). Paste this into your repo root. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = simpler data fetching, less client JS |
| Runtime | Node.js 20+ | `next dev` requires 18+; 20 is current LTS with stable fetch |
| Database | better-sqlite3 (local/dev) / Turso (prod) | Synchronous SQLite is simpler for reads; Turso for edge replication |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, excellent migrations, no codegen bloat |
| Auth | Lucia + Oslo | Session-based auth that works with SQLite out of the box |
| Styling | Tailwind CSS + shadcn/ui | Utility-first, no runtime CSS, copy-paste components (no npm dep) |
| Validation | Zod | Same schemas for API, forms, and DB — single source of truth |
| Testing | Vitest + Playwright | Unit tests in-memory SQLite; E2E against real build |

**Lockfile rule:** `package-lock.json` or `pnpm-lock.yaml` must be committed. No `yarn`.

---

## Folder Structure

