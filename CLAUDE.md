# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated conventions for building a production-ready SaaS with Next.js 15 App Router and SQLite.
> Paste this file at your project root. Claude Code reads it automatically for context.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, simpler data fetching |
| Runtime | Node.js 20+ | `next dev` requires 18+; 20 for native `fetch` stability |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead. Use Turso only if you need edge replicas |
| ORM/Query | Raw SQL + `better-sqlite3` | ORMs hide performance footguns. Migrations in SQL are reviewable and portable |
| Auth | `iron-session` or `jose` (JWT) | No external auth provider dependency. Session in HTTP-only cookie |
| Styling | Tailwind CSS 3.4+ | Utility-first, no runtime CSS-in-JS overhead |
| Forms | Server Actions + `zod` | No `useState` explosion. Validate on the server, re-render with errors |
| Testing | Vitest + Playwright | Unit tests for utilities, E2E for critical flows |

**Lock these versions in `package.json`.** Do not use `latest`.

---

## Folder Structure

