# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, simpler data flow |
| Runtime | Node.js 20+ | `crypto.randomUUID`, native `fetch`, stable `AsyncLocalStorage` |
| Database | better-sqlite3 | Synchronous, fast, zero network overhead. Turso only if you need multi-region |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly |
| Auth | Lucia (or custom session) | No vendor lock-in, works with SQLite natively |
| Styling | Tailwind CSS + shadcn/ui | Utility-first, copy-paste components, no runtime CSS |
| Validation | Zod | Same schemas for API, forms, and DB |

**Lockfile rule:** Use `pnpm`. Commit `pnpm-lock.yaml`. No `package-lock.json` or `yarn.lock`.

---

## Folder Structure

