# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Paste this file at your repo root. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, simpler data flow |
| Runtime | Node.js 20+ | `crypto.randomUUID`, native `fetch`, stable `node:` APIs |
| Database | `better-sqlite3` | Synchronous, fast, zero network latency. Use Turso only if you need multi-region |
| ORM/Query Builder | Drizzle ORM | Type-safe SQL, lightweight, no codegen step, migration files are plain SQL |
| Auth | NextAuth.js v5 (Auth.js) | App Router native, edge-compatible, session in SQLite |
| Styling | Tailwind CSS + shadcn/ui | Utility-first, no runtime CSS, accessible primitives |
| Validation | Zod | Same schemas for API, forms, and DB inserts |
| Testing | Vitest + Playwright | Unit tests in Vitest, E2E in Playwright (real browser) |

**Lockfile rule:** Use `pnpm`. Commit `pnpm-lock.yaml`. No `package-lock.json` or `yarn.lock`.

---

## Folder Structure

