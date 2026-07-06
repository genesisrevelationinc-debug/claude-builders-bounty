# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production SaaS built with Next.js 15 App Router and SQLite.
> Paste this file at the root of your project. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, built on React 19 |
| Runtime | Node.js 20+ | Required for `crypto` global, native fetch stability |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Raw SQL + `better-sqlite3` | No abstraction tax; full control over queries and migrations |
| Auth | `bcryptjs` + `jose` (JWT) | No external auth provider dependency; works offline |
| Styling | Tailwind CSS 4 | Utility-first, zero runtime, works with RSC |
| Forms | Server Actions + `zod` | No client-side form libraries; validate on the server |
| Testing | Vitest + Playwright | Unit tests for utilities, E2E for critical flows |

**Non-negotiable:** We do not use Prisma, Drizzle, or any query builder. Raw SQL keeps the mental model flat and avoids migration lock-in.

---

## Folder Structure

