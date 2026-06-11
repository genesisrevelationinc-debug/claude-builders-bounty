# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Every rule below exists for a reason. If you break one, know why.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, simpler data fetching |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `AsyncLocalStorage` |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead. Use Turso only if you need multi-region |
| ORM/Query Builder | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly. No Prisma (heavy, slow startup) |
| Auth | Lucia + `oslo` | Session-based, works with SQLite out of the box. No JWT (stateless auth is a lie at scale) |
| Styling | Tailwind CSS + `shadcn/ui` | Utility-first, copy-paste components, no runtime CSS |
| Validation | Zod | Same schemas for API, forms, and DB. Single source of truth |
| Testing | Vitest + Playwright | Unit tests for logic, E2E for critical flows |

**Lock these versions.** Do not upgrade major versions without a migration plan.

---

## Folder Structure

