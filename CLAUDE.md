# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your project root and Claude will understand your conventions without asking questions.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = simpler data fetching, less client JS |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `AsyncLocalStorage` |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead. Use Turso only if you need multi-region |
| ORM/Query | Raw SQL + `better-sqlite3` | ORMs hide performance footguns. Migrations in SQL are the source of truth |
| Auth | `oslo` + `better-sqlite3` sessions | No vendor lock-in, works offline, trivial to audit |
| Styling | Tailwind CSS + `shadcn/ui` | Copy-paste components, full control, no runtime CSS |
| Validation | `zod` | Type inference + runtime validation from single source |
| Testing | Vitest + Playwright | Unit tests fast, E2E tests catch integration bugs |

**Non-negotiable:** We do not use Prisma, Drizzle, or any query builder. Raw SQL only.

---

## Folder Structure

