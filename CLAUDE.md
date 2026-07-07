# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS |
| Runtime | Node.js 22+ | `fetch` cache changes, native `crypto` |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-tenant |
| ORM/Query | Drizzle ORM | Type-safe SQL, migrations in TS, no codegen step |
| Auth | `better-auth` | Works with SQLite, no external auth service |
| Styling | Tailwind CSS 4 + CSS variables | No runtime CSS-in-JS, purge by default |
| Forms | Server Actions + `react-hook-form` | Progressive enhancement, no API routes for CRUD |
| Validation | Zod | Same schemas for client, server, and DB |
| Testing | Vitest + Playwright | Unit for logic, E2E for critical flows |

**Lockfile rule:** `package-lock.json` only. Delete `yarn.lock` / `pnpm-lock.yaml` on sight.

---

## Folder Structure

