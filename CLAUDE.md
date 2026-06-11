# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your repo root and Claude will understand your stack without asking questions.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, stable since Oct 2024 |
| Runtime | Node.js 20+ | `fetch` cache changes in 18.x are footguns; 20+ is stable |
| Database | `better-sqlite3` | Synchronous, fast, no connection pool complexity for single-tenant SQLite |
| ORM/Query | Raw SQL via `better-sqlite3` + migration scripts | ORMs hide query plans; we want explicit schema and migrations |
| Auth | `bcryptjs` + `jose` (JWT) | No external auth dependency; works offline, zero cold start |
| Styling | Tailwind CSS 3.4+ | Utility-first, no runtime CSS, works with Server Components |
| Forms | Server Actions + `zod` | No client-side form libraries; validate on server, revalidate paths |
| Testing | Vitest + Playwright | Unit tests in Vitest (fast), E2E in Playwright (real browser) |

**Non-negotiable:** We do not use `pg`, `mysql2`, Prisma, Drizzle, or any other DB driver. SQLite only.

---

## Folder Structure

