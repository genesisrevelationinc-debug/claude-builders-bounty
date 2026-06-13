# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS |
| Runtime | Node.js 20+ | `next/after`, native `fetch` stability |
| Database | `better-sqlite3` | Synchronous, fast, no connection pool hell |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly |
| Auth | Lucia + `oslo` | Session-based, no JWT bloat, works with SQLite |
| Styling | Tailwind CSS + `cn()` | Utility-first, no runtime CSS |
| Forms | `react-hook-form` + Zod | Server validation + client validation same schema |
| Dates | `date-fns` | Tree-shakeable, no mutable global state |
| Testing | Vitest + Playwright | Unit + E2E, fast |

**Lockfile:** `pnpm-lock.yaml` only. No `package-lock.json` or `yarn.lock`.

---

## Folder Structure

