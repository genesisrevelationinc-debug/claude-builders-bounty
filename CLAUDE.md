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
| Styling | Tailwind CSS 3.4 | Utility-first, no runtime CSS, purge-safe by default |
| Components | shadcn/ui | Copy-paste, not `npm install`. We own the code, can customize freely |
| Validation | Zod | Same schemas for API, forms, and DB — single source of truth |
| Testing | Vitest + Playwright | Unit for logic, E2E for critical paths |

**Non-negotiable:** We do NOT use Prisma. The query engine binary adds 45MB+ to Docker images and startup time matters for serverless cold starts. Drizzle compiles to plain SQL.

---

## Folder Structure

