# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated conventions for building a production-ready SaaS with Next.js 15 App Router and SQLite.
> Paste this into your repo root. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | `next/after`, stable `fetch`, native `crypto` |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead, works on any host |
| ORM/Query | Drizzle ORM | Type-safe SQL, migrations in TypeScript, tiny bundle |
| Auth | NextAuth.js v5 (beta) or Lucia + `better-sqlite3` adapter | Session cookies, no JWT in localStorage |
| Styling | Tailwind CSS + shadcn/ui | Utility-first, accessible primitives, copy-paste components |
| Validation | Zod | Same schemas for API, forms, and DB |
| Testing | Vitest + Playwright | Unit tests for utilities, E2E for critical flows |

**Lockfile rule:** Use `pnpm`. Commit `pnpm-lock.yaml`. No `package-lock.json` or `yarn.lock`.

---

## Folder Structure

