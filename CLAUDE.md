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
| Auth | Lucia + `oslo` | Session-based, no JWT complexity, works with SQLite out of the box |
| Styling | Tailwind CSS + `shadcn/ui` | Utility-first, copy-paste components, no version drift |
| Validation | Zod | Same schemas for API, forms, and DB; single source of truth |
| Testing | Vitest + Playwright | Unit tests fast, E2E tests real browser behavior |

**Non-negotiable:** We do not use Prisma. The binary engine and connection pooling add complexity that SQLite doesn't need. Drizzle's SQL-like API is explicit and debuggable.

---

## Folder Structure

