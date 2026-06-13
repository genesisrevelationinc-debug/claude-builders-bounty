# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code. If a rule seems
> arbitrary, the "Why" explains the trade-off. When in doubt, follow the
> pattern, not the exception.

---

## Stack & Versions

| Layer | Choice | Version Constraint |
|-------|--------|-------------------|
| Framework | Next.js | `15.x` (App Router only) |
| Runtime | Node.js | `>= 20` |
| Database | better-sqlite3 | `^11.x` |
| ORM | None — raw SQL via `Database` class | See "SQL / migration conventions" |
| Styling | Tailwind CSS | `^4.x` |
| UI primitives | shadcn/ui | Install via CLI, never manually |
| Auth | Lucia (or custom session) | See "Auth pattern" |
| Validation | Zod | `^3.x` |
| Testing | Vitest + Playwright | — |

**Why no ORM:** better-sqlite3 is synchronous and fast. An ORM adds indirection
and hides query plans. We write SQL to stay close to the database, optimize
early, and avoid N+1 by construction. Migrations are explicit SQL files — no
`sync()`, no `db push`, no schema drift.

---

## Folder Structure

