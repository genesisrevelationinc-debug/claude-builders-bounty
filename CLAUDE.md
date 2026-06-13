# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Paste this into your project root. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `sqlite` |
| Database | `better-sqlite3` | Synchronous, fast, zero network latency for single-tenant SQLite |
| ORM / Query Builder | Drizzle ORM | Type-safe SQL, lightweight, excellent migrations |
| Auth | Lucia (or custom session) | Cookie-based, works edge-to-node, no OAuth lock-in |
| Styling | Tailwind CSS + shadcn/ui | Utility-first, accessible primitives, copy-paste components |
| Validation | Zod | Same schemas for forms, API, and DB |
| Testing | Vitest + Playwright | Unit + E2E without Jest overhead |

**Hard constraints:**
- Next.js must be `>= 15.0.0` (uses `async` Server Components)
- `better-sqlite3` must be `>= 9.0.0` (WAL mode stability)
- Node.js must be `>= 20.0.0` (for `crypto.randomUUID()`)

---

## Folder Structure

