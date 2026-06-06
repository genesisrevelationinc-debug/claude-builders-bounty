# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Paste this file at your repo root. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = simpler data fetching, no API route boilerplate for reads |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `sqlite` support |
| Database | `better-sqlite3` | Synchronous, fast, no connection pool complexity for single-node deploys |
| ORM/Query Builder | Raw SQL + `better-sqlite3` | SQLite is simple; ORMs add indirection without benefit at small scale. Migrations in plain SQL |
| Auth | `bcryptjs` + `jose` (JWT) | No external auth service dependency. Session tokens in `HttpOnly` cookies |
| Styling | Tailwind CSS 3.4+ | Utility-first, zero runtime, works with Server Components |
| Forms | Server Actions + `zod` | No `useState` form boilerplate. Validate on the server, re-render with errors |
| Testing | Vitest + Playwright | Unit tests for utilities, E2E for critical user flows |

**Non-negotiable:** All database access happens in Server Components or Server Actions. No `fetch` wrappers in client components that hit `/api/*` routes for data that could be fetched server-side.

---

## Folder Structure

