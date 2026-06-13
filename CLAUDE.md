# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Paste this into your project root. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | `next/after`, stable `fetch` cache, native `crypto` |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, excellent migrations |
| Auth | Lucia (or custom session) | Cookie-based sessions stored in SQLite, no external deps |
| Styling | Tailwind CSS + shadcn/ui | Utility-first, accessible primitives, copy-paste components |
| Validation | Zod | Schema validation shared between server and client |
| Testing | Vitest + Playwright | Unit tests for logic, E2E for critical flows |

**Non-negotiable:** We do not use Prisma. It bundles a query engine, adds 50MB+ to Docker images, and its SQLite support is second-class. Drizzle generates plain SQL and stays out of the way.

---

## Folder Structure

