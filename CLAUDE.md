# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Paste this file at the root of your project. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable ESM |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| Query Builder | `dZK` (or raw SQL) | No ORM. ORMs hide migrations, bloat bundles, and fail at complex queries |
| Auth | `oslo` + `bcryptjs` | Stateless sessions in SQLite, no external auth service dependency |
| Styling | Tailwind CSS 3.4 | Utility-first, zero runtime, design system via config |
| Forms | Server Actions + `zod` | No client-side form libraries. Validate on the server, revalidate paths |
| Deployment | Docker + Fly.io / Railway | SQLite is a file; use LiteFS or single-node with volume for MVP |

**Non-negotiable:** We do not use Prisma, Drizzle, or any ORM. They generate migration files that are harder to review than raw SQL and couple schema to TypeScript types in ways that break during refactors.

---

## Folder Structure

