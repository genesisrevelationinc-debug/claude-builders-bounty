# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated conventions for building a production SaaS with Next.js 15 App Router and SQLite.
> Paste this file at your project root. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, stable since 15.x |
| Runtime | Node.js 20+ | `next dev` requires 18+, 20+ for native `fetch` stability |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly |
| Auth | Lucia (or custom session) | No OAuth lock-in, works with SQLite natively |
| Styling | Tailwind CSS + shadcn/ui | Utility-first, copy-paste components, no runtime CSS |
| Validation | Zod | Same schemas for API, forms, and DB |
| Testing | Vitest + Playwright | Unit tests in Node, E2E in real browser |

**Non-negotiable:** We do not use `next-auth` (locks you into OAuth) or Prisma (heavy, slow on SQLite). Every dependency must justify its weight.

---

## Folder Structure

