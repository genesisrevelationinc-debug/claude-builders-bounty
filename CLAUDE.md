# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite (better-sqlite3 or Turso). Paste this into your repo root. Claude Code reads this automatically.

---

## Stack & Versions

| Layer | Choice | Rationale |
|-------|--------|-----------|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts. Pages Router is not used. |
| Runtime | Node.js 20+ | Native `fetch`, stable `crypto`, `AsyncLocalStorage` for request context. |
| Database | SQLite via `better-sqlite3` (local) or `@libsql/client` (Turso/edge) | Single file, zero config, runs anywhere. Turso for edge deployment. |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, no hidden queries, migration files are plain SQL. |
| Auth | `next-auth` v5 (Auth.js) with JWT sessions | Edge-compatible, SQLite adapter available, no external auth service required. |
| Styling | Tailwind CSS + `shadcn/ui` | Utility-first, no runtime CSS, components are copy-paste owned code. |
| Forms | `react-hook-form` + `zod` | Server-side validation first, client-side for UX only. |
| Testing | Vitest (unit), Playwright (E2E) | Fast unit tests, real browser for critical paths. |

**Lock these versions.** Do not upgrade major versions without updating this file.

---

## Folder Structure

