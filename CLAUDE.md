# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code.  
> Last updated: 2026-03-01

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, built on React 19 |
| Runtime | Node.js 20+ | `fetch` is stable, native `crypto`, no polyfills needed |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM / Query | Raw SQL via `better-sqlite3` | SQLite is simple; ORMs add complexity without benefit here |
| Migrations | Custom Node.js scripts | One `.sql` file per migration, run in deterministic order |
| Auth | `bcryptjs` + `jose` (JWT) | No external auth provider dependency, works offline |
| Styling | Tailwind CSS 3.4 | Utility-first, no runtime CSS-in-JS overhead |
| Forms | Server Actions + `useFormState` | No client-side form libraries; let the server own validation |
| Testing | Vitest + Playwright | Unit tests for utilities, E2E for critical user flows |

**Non-negotiable:** We do not use Prisma, Drizzle, or any query builder.  
**Reason:** SQLite schemas are small and stable. Raw SQL is explicit, debuggable, and avoids dependency bloat. Migrations are plain `.sql` files that any DBA can read.

---

## Folder Structure

