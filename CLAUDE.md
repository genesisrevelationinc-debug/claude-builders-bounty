# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code.  
> Last updated: 2026-03

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable ESM |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Drizzle ORM | Type-safe SQL, migrations in code, no query builder lock-in |
| Auth | Lucia (or custom session) | No vendor lock-in, works with SQLite natively |
| Styling | Tailwind CSS + shadcn/ui | Copy-paste components, no runtime CSS |
| Validation | Zod | Same schemas for API + forms |
| Testing | Vitest + Playwright | Unit + E2E, both fast |

**Non-negotiable:** We do not use Prisma with SQLite. Prisma's migration engine has race conditions on SQLite and its query engine adds 14MB to the bundle. Use Drizzle or raw `better-sqlite3`.

---

## Folder Structure

