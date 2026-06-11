# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code. If Claude suggests something that contradicts this file, this file wins.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server-first, streaming, stable |
| Runtime | Node.js 20+ | `crypto.randomUUID` native, no polyfills |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-tenant deploys |
| ORM/Query | Raw SQL + `better-sqlite3` | ORMs hide performance cliffs; we own our schema |
| Migrations | Custom Node.js scripts | `node scripts/migrate.js` — no hidden migration frameworks |
| Auth | `bcrypt` + `jose` (JWT) | No bloated auth libraries; we control the session shape |
| Styling | Tailwind CSS 3.4+ | Utility-first, no runtime CSS |
| Forms | Server Actions + `useFormState` | No `react-hook-form` — Server Actions handle validation and errors |
| Validation | `zod` | Single source of truth for schemas, shared client/server |
| Testing | Vitest + `better-sqlite3` (in-memory) | Same DB in tests as production |

**Non-negotiable:** SQLite is file-backed. One database per tenant (not one table with `tenant_id`). This eliminates row-level security complexity and makes backups trivial (`cp db.sqlite db.sqlite.backup`).

---

## Folder Structure

