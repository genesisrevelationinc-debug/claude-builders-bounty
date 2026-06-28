# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Paste this file at the root of your project. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `AsyncLocalStorage` |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead, works in Server Components |
| ORM/Query | Raw SQL + `better-sqlite3` | No ORM bloat; SQL is the source of truth. Use `db.prepare()` for everything |
| Migrations | Custom `.sql` files + Node script | Schema changes must be reviewable, reversible, and run in a transaction |
| Auth | `iron-session` + bcrypt | Stateless sessions, no external auth service dependency |
| Styling | Tailwind CSS 3.4+ | Utility-first, zero runtime, colocated with components |
| Forms | Server Actions + `useFormState` | No API routes for mutations; progressive enhancement built-in |
| Validation | `zod` | Share schemas between Server Actions and client |
| Testing | Vitest (unit) + Playwright (E2E) | Fast unit tests, real browser for critical paths |

**Lockfile rule:** `package-lock.json` is the source of truth. Delete `yarn.lock` / `pnpm-lock.yaml` on sight.

---

## Folder Structure

