# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Paste this into your project root. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | `crypto.randomUUID`, native `fetch`, stable `sqlite` |
| Database | `better-sqlite3` | Synchronous, fast, zero-config for single-tenant deploys. Use `libsql` (Turso) only if you need edge replication |
| ORM/Query | Raw SQL + `drizzle-orm` | Drizzle for type-safe queries; raw SQL for migrations and complex reports |
| Auth | `bcryptjs` + `jose` (JWT) | No external auth dependency. Sessions stored in SQLite |
| Styling | Tailwind CSS 3.4+ | Utility-first, no runtime CSS-in-JS overhead |
| Forms | Server Actions + `zod` | No client-side form libraries. Validate on the server |
| Testing | Vitest + `better-sqlite3` (in-memory) | Same DB in tests as production |

**Non-negotiable:** All code targets Node.js runtime. Do not use Edge Runtime for DB operations—`better-sqlite3` is native and blocks; run it in Node.

---

## Folder Structure

