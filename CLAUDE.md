# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Paste this file at the root of your project. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `sqlite` |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly |
| Auth | `oslo` + `bcryptjs` | Minimal, no vendor lock-in, works with any user table schema |
| Styling | Tailwind CSS 3.4+ | Utility-first, no runtime CSS-in-JS overhead |
| Forms | Server Actions + `zod` | No client-side form libraries needed |
| Testing | Vitest + Playwright | Unit + E2E without Jest's config complexity |

**Non-negotiable:** We do not use `pg`, `mysql2`, or Prisma. SQLite is the production database. If you need read replicas later, use LiteStream or migrate then—not now.

---

## Folder Structure

