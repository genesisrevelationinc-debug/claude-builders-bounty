# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Paste this file at the root of your project. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `fs/promises` |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Drizzle ORM | Type-safe SQL, zero runtime bloat, migration-first |
| Auth | NextAuth.js v5 (Auth.js) | Edge-compatible, JWT sessions, OAuth built-in |
| Styling | Tailwind CSS 3.4 | Utility-first, no runtime CSS-in-JS overhead |
| Forms | React Server Actions + `zod` | No API boilerplate, validated at the edge |
| Testing | Vitest + Playwright | Unit tests in-memory SQLite, E2E on real build |

**Lock these versions.** Do not upgrade major versions without a migration plan.

---

## Folder Structure

