# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code. Every rule has a reason.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, simpler data fetching |
| Runtime | Node.js 20+ | `next dev` requires 18+; 20 is current LTS with stable fetch |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead. Use Turso only if you need multi-region |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, no hidden queries, great migrations |
| Auth | Lucia + `better-sqlite3` adapter | Session-based, no JWT bloat, works with OAuth providers |
| Styling | Tailwind CSS + shadcn/ui | Utility-first, no runtime CSS, copy-paste components you own |
| Validation | Zod | Same schemas for API, forms, and DB |
| Testing | Vitest + Playwright | Unit tests fast, E2E tests catch routing regressions |

**Lock these versions.** Do not upgrade major versions without a migration plan.

---

## Folder Structure

