# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated rules for building production SaaS with Next.js 15 App Router and SQLite (better-sqlite3 or Turso).  
> Copy this file to your repo root. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Lock Version |
|-------|--------|--------------|
| Framework | Next.js 15 (App Router) | `next@^15.0.0` |
| Runtime | Node.js 20+ | `.nvmrc` required |
| Database | SQLite via `better-sqlite3` (local/dev) or `@libsql/client` (Turso/prod) | Pin exact |
| ORM | Drizzle ORM | `drizzle-orm` + `drizzle-kit` |
| Auth | Lucia (or custom session with `iron-session`) | Avoid OAuth-only providers |
| Styling | Tailwind CSS + shadcn/ui | No other CSS-in-JS |
| Validation | Zod | Every external boundary |
| Testing | Vitest (unit) + Playwright (E2E) | No Jest |

**Rule:** Never add a dependency without updating this table and justifying in PR description.

---

## Folder Structure

