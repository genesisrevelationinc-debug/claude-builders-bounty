# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production SaaS built with Next.js 15 App Router and SQLite (better-sqlite3 or Turso). Follow these rules without exception. If a pattern isn't listed here, default to Next.js docs and these principles: type safety first, server-first rendering, explicit over implicit.

---

## Stack & Versions

| Layer | Choice | Rationale |
|-------|--------|-----------|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | `crypto` global, native fetch, stable ESM |
| Database | better-sqlite3 (local/dev) / Turso (prod) | Synchronous SQLite for writes, libSQL for edge replication |
| ORM/Query | Drizzle ORM | Type-safe SQL, zero runtime bloat, migration tooling built-in |
| Auth | Lucia (or NextAuth v5) | Session-based, works with Edge, no vendor lock-in |
| Styling | Tailwind CSS + shadcn/ui | Utility-first, accessible primitives, copy-paste ownership |
| Validation | Zod | Same schemas for API, forms, and DB |
| Testing | Vitest + Playwright | Unit tests for logic, E2E for critical flows |

**Lock these versions.** Do not upgrade major versions without updating this file.

---

## Folder Structure

