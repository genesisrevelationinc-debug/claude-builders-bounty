# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code. If Claude suggests something that contradicts this file, follow this file.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, stable |
| Runtime | Node.js 20+ | `next` CLI requires it; use `fetch` globals |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query Builder | Drizzle ORM | Type-safe SQL, migrations in TypeScript, no codegen step |
| Auth | Lucia + `better-sqlite3` adapter | Session-based, works without external services |
| Styling | Tailwind CSS + shadcn/ui | Utility-first, copy-paste components, no runtime CSS |
| Validation | Zod | Same schemas for API, forms, and DB |
| Testing | Vitest + Playwright | Unit tests for utilities, E2E for critical flows |

**Non-negotiable:** We do not use Prisma. It generates a client, hides SQL, and has poor SQLite support.

---

## Folder Structure

