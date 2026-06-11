# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code. If a rule seems arbitrary, the "Why" explains the trade-off.

---

## Stack & Versions

| Layer | Choice | Version Constraint |
|-------|--------|------------------|
| Framework | Next.js | 15.x (App Router only) |
| Runtime | Node.js | 20.x LTS |
| Database | SQLite | `better-sqlite3` for local, `libsql` (Turso) for prod |
| ORM/Query Builder | Drizzle ORM | Latest stable |
| Migrations | Drizzle Kit | `drizzle-kit generate` + `migrate.ts` script |
| Auth | Lucia (or custom session) | SQLite-backed sessions |
| Styling | Tailwind CSS | 3.x |
| UI Components | shadcn/ui | Install via CLI, never manually |
| Validation | Zod | All external inputs |
| Testing | Vitest + Playwright | Unit + E2E |

**Why this stack:** SQLite eliminates infrastructure overhead for 0-10k users. `better-sqlite3` is synchronous and fast for local dev. Turso's `libsql` gives us edge replication without changing SQL dialect. Next.js 15 App Router lets us colocate data fetching with UI. No PostgreSQL until we have a concrete scaling bottleneck.

---

## Folder Structure

