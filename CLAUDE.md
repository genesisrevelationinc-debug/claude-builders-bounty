# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code. Claude Code uses this file for context.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, stable |
| Runtime | Node.js 20+ | LTS, native `fetch`, `crypto` |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Raw SQL + `better-sqlite3` | No abstraction leak; schema is source of truth |
| Migrations | Custom Node.js scripts | `node scripts/migrate.js` — no ORM magic |
| Styling | Tailwind CSS 3.4+ | Utility-first, no runtime CSS |
| Forms | Server Actions + `zod` | No client-side form libraries |
| Auth | `bcryptjs` + `jose` (JWT) | Stateless, no session store needed |
| Testing | Vitest + Playwright | Unit + E2E, no Jest |

**Non-negotiable:** We do not use Prisma, Drizzle, or any query builder. Raw SQL only.

---

## Folder Structure

