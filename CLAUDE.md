# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code.  
> Goal: eliminate decision fatigue, ship faster, maintain at scale.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, better SEO |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `node:` prefix |
| Database | `better-sqlite3` | Synchronous, fast, zero connection pooling complexity |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, no hidden queries |
| Auth | Lucia (or custom session) | No vendor lock-in, works with SQLite natively |
| Styling | Tailwind CSS + shadcn/ui | Utility-first, copy-paste components, no dep drift |
| Validation | Zod | Same schemas for API, forms, and DB |
| Testing | Vitest + Playwright | Unit: fast. E2E: real browser. No overlap. |

**Pinned in `package.json`:** Use exact versions. No `^`. Renovate weekly.

---

## Folder Structure

