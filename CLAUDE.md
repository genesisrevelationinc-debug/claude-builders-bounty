# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Paste this file at the root of your project. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable ESM |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM / Query Builder | Drizzle ORM | Type-safe SQL, lightweight, excellent migrations |
| Auth | NextAuth.js v5 (Auth.js) | Edge-compatible, JWT sessions, OAuth providers |
| Styling | Tailwind CSS 3.4 + shadcn/ui | Utility-first, accessible primitives, no CSS-in-JS runtime |
| Validation | Zod | Schema validation shared between server and client |
| Testing | Vitest + Playwright | Unit tests for logic, E2E for critical flows |

**Non-negotiable:** We use the App Router. Pages Router is not supported in this template.

---

## Folder Structure

