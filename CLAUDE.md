# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this at the root of any greenfield Next.js 15 + SQLite project. No clarifying questions should be needed.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, simpler data fetching |
| Runtime | Node.js 20+ | `next/after`, native `fetch` with `keepalive`, stable `crypto` |
| Database | `better-sqlite3` | Synchronous, fast, zero network latency, perfect for single-tenant SaaS |
| ORM / Query Builder | Drizzle ORM | Type-safe SQL, lightweight, no codegen bloat, migrations in `.sql` |
| Auth | Lucia (or custom session with `iron-session`) | No vendor lock-in, works with any DB, minimal bundle size |
| Styling | Tailwind CSS + shadcn/ui | Copy-paste components, no runtime CSS, easy to customize |
| Validation | Zod | Same schemas for API, forms, and DB; runs on edge and node |
| Testing | Vitest + Playwright | Unit tests in-memory SQLite, E2E against real build |

**Hard constraint:** We do not use Turso, PlanetScale, or any remote database in development or for single-tenant deployments. The network boundary is the enemy of simplicity. If we ever need multi-region, we migrate then—not before.

---

## Folder Structure

