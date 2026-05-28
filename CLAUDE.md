# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code. If a rule seems arbitrary, there's a reason—ask.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, no API route boilerplate for data fetching |
| Runtime | Node.js 20+ | `crypto.randomUUID` native, stable `fetch`, `node:sqlite` available if we ever need it |
| Database | `better-sqlite3` | Synchronous, fast, zero connection pooling complexity. Turso only if we need multi-region (rare at this stage) |
| ORM/Query Builder | Drizzle ORM | Type-safe SQL, zero runtime bloat, migrations are just SQL files |
| Auth | Lucia (or custom session cookies) | Don't bring in NextAuth/Auth0 until you need social login. SQLite sessions are trivial |
| Styling | Tailwind CSS + shadcn/ui | Copy-paste components, no version drift, full control |
| Validation | Zod | Same schemas for API, forms, and DB |

**Lock these versions.** Do not upgrade major versions without a migration plan.

---

## Folder Structure

