# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Paste this file at the root of your project. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `sqlite` |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead, works in Docker |
| ORM/Query | Raw SQL + `better-sqlite3` | No ORM bloat; SQL is the source of truth |
| Migrations | `node-sqlite-migrate` or custom script | Versioned, reversible, checked in CI |
| Auth | `lucia` + `oslo` or `next-auth` v5 beta | Session-based, no JWT in localStorage |
| Styling | Tailwind CSS + shadcn/ui | Utility-first, accessible, copy-paste components |
| Validation | `zod` | Schema-first, infers TypeScript types |
| Testing | Vitest + Playwright | Unit in Node, E2E in real browser |

**Non-negotiable:** We do not use Prisma, Drizzle, or any query builder. Raw SQL with typed wrappers only.

---

## Folder Structure

