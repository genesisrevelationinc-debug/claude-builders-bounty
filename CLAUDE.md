# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Paste this file at the root of your project. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `AsyncLocalStorage` |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead, perfect for single-node deploys |
| ORM / Query Builder | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly |
| Auth | NextAuth.js v5 (Auth.js) | Edge-compatible, JWT sessions, OAuth + credentials |
| Styling | Tailwind CSS + shadcn/ui | Utility-first, copy-paste components, no runtime CSS |
| Validation | Zod | Schema validation shared between server and client |
| Testing | Vitest + Playwright | Unit tests for utilities, E2E for critical flows |

**Lock these versions.** Do not upgrade major versions without a migration plan.

---

## Folder Structure

