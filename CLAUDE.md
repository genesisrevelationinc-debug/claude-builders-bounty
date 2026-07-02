# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Copy this file to the root of your project. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `sqlite` module |
| Database | `better-sqlite3` | Synchronous, fast, zero-config for single-tenant SaaS |
| ORM/Query | Raw SQL + `better-sqlite3` | No abstraction leak; schema is the source of truth |
| Migrations | Custom Node.js scripts | One `.sql` file per migration, run in order, never skip |
| Auth | `bcryptjs` + `jose` (JWT) | No heavy auth library; we own the session cookie |
| Styling | Tailwind CSS 4 | Utility-first, no runtime CSS |
| Forms | Server Actions + `zod` | No client-side form libraries; validate on the server |
| Testing | Vitest + `better-sqlite3` in-memory | Same DB in tests as production |

**Lock these versions.** Do not upgrade major versions without updating this file.

---

## Folder Structure

