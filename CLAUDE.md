# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your repo root. Claude reads this automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, stable since 15.1 |
| Runtime | Node.js 20+ | `next dev` requires 18+, we target LTS |
| Database | better-sqlite3 | Synchronous, fast, zero network overhead for single-node deploys |
| ORM / Query Builder | Drizzle ORM | Type-safe SQL, migrations in TS, no codegen step |
| Auth | Lucia (or custom session) | Lightweight, works with SQLite, no vendor lock-in |
| Styling | Tailwind CSS + shadcn/ui | Utility-first, copy-paste components, no runtime CSS |
| Validation | Zod | Same schemas for API, forms, and DB |
| Testing | Vitest + Playwright | Unit tests in Node, E2E in real browser |

**Non-negotiable:** We do not use Prisma. The binary engine and connection pooling add complexity with no benefit for SQLite.

---

## Folder Structure

