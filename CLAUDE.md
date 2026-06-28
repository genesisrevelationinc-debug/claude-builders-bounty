# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated conventions for building a production-ready SaaS with Next.js 15 App Router and SQLite.
> Paste this file at the root of your project. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, built on React 19 |
| Runtime | Node.js 20+ | Native `fetch`, `crypto`, `structuredClone`; LTS stability |
| Database | `better-sqlite3` | Synchronous, fast, zero-config for single-node deploys. Use Turso only if you need multi-region |
| ORM/Query Builder | Drizzle ORM | Type-safe SQL, lightweight, excellent migrations, no codegen bloat |
| Auth | Lucia (or custom session) | Session-based, works with SQLite out of the box, no vendor lock-in |
| Styling | Tailwind CSS 4 | Utility-first, zero-runtime, design system via config |
| Forms | React Hook Form + Zod | Client validation mirrors server validation, single source of truth |
| Deployment | Docker + Fly.io / Railway | SQLite is a file; persist it via volume. Don't use Vercel for SQLite |

**Non-negotiable:** We do not use Prisma. It bundles a query engine, has slow cold starts, and its migration system fights SQLite's simplicity.

---

## Folder Structure

