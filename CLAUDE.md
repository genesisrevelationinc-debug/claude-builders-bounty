# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite (better-sqlite3).
> Paste this file at the root of your project. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | Native `fetch`, stable `crypto`, `better-sqlite3` compatibility |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM / Query Builder | Drizzle ORM | Type-safe SQL, lightweight, excellent migrations |
| Auth | Lucia + `better-sqlite3` adapter | Session-based, no JWT bloat, works offline |
| Styling | Tailwind CSS + shadcn/ui | Utility-first, accessible primitives, copy-paste components |
| Validation | Zod | Same schemas for client, server, and DB |
| Testing | Vitest + Playwright | Unit tests for logic, E2E for critical flows |

**Non-negotiable:** We do not use Prisma with SQLite. Prisma's query engine adds a Rust binary, connection pooling that conflicts with `better-sqlite3`'s synchronous model, and migration files that are hard to review.

---

## Folder Structure

