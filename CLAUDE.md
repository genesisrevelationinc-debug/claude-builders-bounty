# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Paste this file at your repo root. Claude Code reads it automatically for context.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `sqlite` |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly |
| Auth | Lucia (or custom session) | Cookie-based sessions stored in SQLite, no external deps |
| Styling | Tailwind CSS + shadcn/ui | Utility-first, accessible primitives, no runtime CSS |
| Validation | Zod | Schema validation shared between server and client |
| Testing | Vitest + Playwright | Unit tests for logic, E2E for critical flows |

**Non-negotiable:** We do not use Prisma. The query engine adds complexity and binary bloat that contradicts SQLite's simplicity.

---

## Folder Structure

