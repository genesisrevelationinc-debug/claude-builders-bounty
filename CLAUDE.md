# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code.  
> Goal: eliminate decision fatigue, ship faster, maintain longer.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server-first, streaming, stable |
| Runtime | Node.js 20+ | LTS, native `fetch`, `crypto` |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly |
| Auth | Lucia + `better-sqlite3` adapter | Session-based, no JWT bloat, works offline |
| Styling | Tailwind CSS 3.4+ | Utility-first, no runtime CSS |
| Components | shadcn/ui | Copy-pasteable, no dependency lock-in |
| Validation | Zod | Same schemas for API + forms |
| Testing | Vitest + Playwright | Unit + E2E, fast |

**Lockfile rule:** `package-lock.json` only. No `yarn.lock`, no `pnpm-lock.yaml`. Consistency > speed.

---

## Folder Structure

