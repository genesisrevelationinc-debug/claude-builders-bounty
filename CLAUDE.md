# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, stable |
| Runtime | Node.js 20+ | `fetch` cache control, native `crypto` |
| Database | `better-sqlite3` | Synchronous, fast, zero network latency for single-node deploys |
| Schema / Migrations | Custom SQL scripts | No ORM bloat; SQL is the source of truth |
| Styling | Tailwind CSS 3.4+ | Utility-first, no runtime CSS-in-JS overhead |
| Auth | `iron-session` + bcrypt | Stateless sessions, no external auth service dependency |
| Validation | Zod | Type inference, runtime safety, single source of truth |
| Testing | Vitest + Playwright | Unit + E2E without Jest's module resolution pain |

**Non-negotiable:** We do not use Prisma, Drizzle, or any query builder. Raw SQL via `better-sqlite3` keeps the mental model flat and the bundle small.

---

## Folder Structure

