# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Paste this file at the root of your project. Claude Code will read it automatically and understand your stack without asking questions.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | `crypto` global, native fetch, stable ESM |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Raw SQL + `better-sqlite3` | No abstraction tax; schema lives in `.sql` files |
| Auth | `iron-session` + bcrypt | Stateless sessions, no Redis/DB dependency for auth state |
| Styling | Tailwind CSS 3.4+ | Utility-first, zero runtime, design system via config |
| Forms | Server Actions + `zod` | No API routes needed; validation co-located with action |
| Testing | Vitest + Playwright | Unit tests for utilities, E2E for critical flows |

**Non-negotiable:** We deploy to a single server or VPS. SQLite is file-backed; no Turso, no connection pooling, no distributed SQLite. If you outgrow this, migrate to Postgres explicitly.

---

## Folder Structure

