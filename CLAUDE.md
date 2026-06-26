# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, stable |
| Runtime | Node.js 20+ | `crypto` global, native fetch, stable ESM |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Raw SQL + `better-sqlite3` | No abstraction tax; schema lives in `.sql` files |
| Migrations | Custom runner (see below) | No ORM lock-in; versioned, reversible, testable |
| Auth | `iron-session` + bcrypt | Stateless sessions, no external auth service dependency |
| Styling | Tailwind CSS 3.4 | Utility-first, zero runtime, design system friendly |
| Forms | Server Actions + `zod` | No API boilerplate; validation co-located with action |
| Testing | Vitest + Playwright | Unit tests fast, E2E tests realistic |

**We do not use:** Prisma (migrations are opaque, slow on SQLite), tRPC (Server Actions replace it), PlanetScale/Neon (network latency, cost), Redux/Zustand (Server Components make most client state obsolete).

---

## Folder Structure

