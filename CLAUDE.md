# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code.  
> Goal: eliminate decision fatigue, ship faster, maintain forever.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS |
| Runtime | Node.js 20+ | `crypto` global, native fetch, stable |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Drizzle ORM | Type-safe SQL, migrations in code, no magic |
| Auth | Lucia + `oslo` | Session-based, works with SQLite, no OAuth lock-in |
| Styling | Tailwind CSS + `cn()` | Utility-first, zero runtime, `clsx` + `tailwind-merge` |
| Forms | Server Actions + `zod` | No API routes needed, validation co-located |
| Testing | Vitest + Playwright | Unit + E2E, fast, same config syntax |

**Non-negotiable:** We do not use `turso` or any remote SQLite. The whole point of SQLite is zero network latency. If you need multi-node, switch to Postgres. Don't pretend SQLite is distributed.

---

## Folder Structure

