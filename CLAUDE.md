# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your repo root and Claude will understand how to work with your codebase without asking clarifying questions.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, stable since 15 |
| Runtime | Node.js 20+ | `crypto.randomUUID`, native `fetch`, stable ESM |
| Database | `better-sqlite3` | Synchronous, fast, no connection pool complexity for SQLite |
| ORM/Query | Raw SQL + `better-sqlite3` | SQLite is simple; ORMs add indirection without benefit |
| Auth | `oslo` + `bcryptjs` | Minimal, no OAuth lock-in, works with any user table schema |
| Styling | Tailwind CSS 3.4 | Utility-first, no runtime CSS, works with Server Components |
| Forms | Server Actions + `zod` | No client-side form libraries, validate on the server |
| Testing | Vitest + Playwright | Unit tests for utilities, E2E for critical flows |

**Non-negotiable:** We do not use Prisma, Drizzle, or any other ORM. SQLite schemas are simple enough that raw SQL is clearer and has zero abstraction cost.

---

## Folder Structure

