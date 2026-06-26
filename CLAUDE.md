# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated conventions for a production SaaS built with Next.js 15 App Router and SQLite.
> Paste this file at your project root. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, built on React 19 |
| Runtime | Node.js 20+ | Required for `crypto` and native `fetch` stability |
| Database | `better-sqlite3` | Synchronous, fast, zero network latency for single-node deploys |
| ORM / Query Builder | Drizzle ORM | Type-safe SQL, lightweight, excellent migrations |
| Auth | Lucia + `oslo` | Session-based, works with SQLite, no third-party lock-in |
| Styling | Tailwind CSS + `shadcn/ui` | Utility-first, accessible primitives, copy-paste components |
| Validation | Zod | Same schemas for API, forms, and DB |
| Testing | Vitest + Playwright | Unit tests run fast; E2E covers critical paths |

**Non-negotiable:** We do not use Prisma. It bundles a query engine that doubles Docker image size and adds 5+ seconds to cold starts. Drizzle compiles to plain SQL.

---

## Folder Structure

