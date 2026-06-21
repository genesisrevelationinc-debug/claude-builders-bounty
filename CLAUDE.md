# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Paste this file at the root of your project. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, built on React 19 |
| Runtime | Node.js 20+ | Required for `fetch` improvements, `crypto` APIs, native `fetch` in tests |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead. Use Turso only if you need multi-region (see "What We Don't Do") |
| ORM/Query Builder | Drizzle ORM | Type-safe SQL, lightweight, excellent migrations, no codegen bloat |
| Auth | Lucia + `oslo` | Session-based auth, works with any OAuth provider, no vendor lock-in |
| Styling | Tailwind CSS + `shadcn/ui` | Utility-first, copy-paste components, no npm dependency hell for UI |
| Validation | Zod | Same schemas for API, forms, and DB. Single source of truth |
| Testing | Vitest + `next-test-api-route` | Unit tests for utilities; integration tests for API routes |

**Lock these versions in `package.json`:** `next` >= 15.0.0, `react` >= 19.0.0, `better-sqlite3` >= 11.0.0, `drizzle-orm` >= 0.30.0.

---

## Folder Structure

