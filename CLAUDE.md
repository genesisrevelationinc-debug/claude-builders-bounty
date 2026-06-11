# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, stable |
| Runtime | Node.js 20+ | `fetch` cache control, native `crypto`, stable ESM |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly |
| Auth | Lucia + `better-sqlite3` adapter | Session-based, no JWT in cookies, works offline |
| Styling | Tailwind CSS + shadcn/ui | Utility-first, accessible primitives, copy-paste components |
| Validation | Zod | Same schemas for API, forms, and DB |
| Testing | Vitest + Playwright | Unit + E2E, fast |

**Lockfile:** `pnpm-lock.yaml` only. No `package-lock.json` or `yarn.lock`.

---

## Folder Structure

