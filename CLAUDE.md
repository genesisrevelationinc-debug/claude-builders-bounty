# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production SaaS built with Next.js 15 App Router and SQLite.
> Paste this into your project root. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, built on React 19 |
| Runtime | Node.js 20+ | Required for `crypto` global, native fetch, stable `node:` prefixes |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead, perfect for single-tenant SaaS |
| ORM/Query | Raw SQL + `better-sqlite3` | No abstraction tax; schema is the source of truth |
| Migrations | Custom Node.js scripts | One less dependency; total control over transaction boundaries |
| Auth | `iron-session` + bcrypt | Stateless sessions, no Redis/DB session table needed |
| Styling | Tailwind CSS 3.4+ | Utility-first, zero runtime overhead, design system via config |
| Forms | Server Actions + `useActionState` | No client-side form libraries; progressive enhancement by default |
| Validation | Zod | Type-safe schemas shared between server and client |
| Testing | Vitest + Playwright | Unit tests for utilities, E2E for critical flows |

**Non-negotiable:** We do not use `turso` or any remote SQLite. The whole point of SQLite is zero network latency. If you need multi-region, use Postgres.

---

## Folder Structure

