# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production SaaS built with Next.js 15 App Router and SQLite.
> Paste this into your project root. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = simpler data flow, less client JS |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `AsyncLocalStorage` |
| Database | `better-sqlite3` | Synchronous, fast, no connection pool complexity for SQLite |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly |
| Auth | Lucia (or custom session) | Session cookies, no JWT in localStorage |
| Styling | Tailwind CSS + shadcn/ui | Copy-paste components, no runtime CSS-in-JS |
| Validation | Zod | Same schemas on server and client |
| Testing | Vitest + Playwright | Unit tests for logic, E2E for critical flows |

**Hard rule:** No `pg`, `mysql2`, or other drivers. SQLite only. Single file (`local.db`) for dev, Turso/libsql for prod.

---

## Folder Structure

