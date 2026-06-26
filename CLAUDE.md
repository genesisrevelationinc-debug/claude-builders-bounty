# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, stable |
| Runtime | Node.js 20+ | `crypto` global, native fetch, performance |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Drizzle ORM | Type-safe SQL, migrations in code, no hidden queries |
| Auth | `oslo` + `argon2` | Stateless sessions, no OAuth lock-in, works at edge |
| Styling | Tailwind CSS 3.4 | Utility-first, zero runtime, design system via config |
| Forms | Server Actions + `zod` | No client state needed, validation on both boundaries |
| Testing | Vitest + Playwright | Unit where it matters, E2E for critical paths |

**Non-negotiable:** We deploy to a single VPS (Fly.io, Railway, or similar). SQLite is a file on disk. If you need multi-node, fork the project and switch to Postgres—don't try to make SQLite work across nodes.

---

## Folder Structure

