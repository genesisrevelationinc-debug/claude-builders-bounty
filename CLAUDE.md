# CLAUDE.md — Next.js 15 + SQLite SaaS

> This file is the source of truth for how this codebase works. Claude Code reads it before doing anything. If something here conflicts with a general best practice, this file wins.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, simpler data fetching |
| Runtime | Node.js 20+ | `next dev` requires it; we use native `crypto` and `fetch` |
| Database | better-sqlite3 | Synchronous, fast, zero network overhead. Perfect for single-node deploys |
| ORM/Query | Raw SQL + `better-sqlite3` | No ORM bloat. SQL is the source of truth. Migrations are version-controlled |
| Auth | Lucia (or custom session) | SQLite-native, no external auth service dependency |
| Styling | Tailwind CSS | Utility-first, no runtime CSS-in-JS overhead |
| Forms | Server Actions + `useFormState` | No API routes needed for mutations |
| Validation | Zod | Same schemas on server and client |
| Testing | Vitest + Playwright | Unit for logic, E2E for critical flows |

**Hard rule:** No switching to PostgreSQL/MySQL without a written ADR in `/docs/`. SQLite is not a toy database.

---

## Folder Structure

