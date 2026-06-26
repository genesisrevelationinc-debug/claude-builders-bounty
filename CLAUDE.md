# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Paste this file at your repo root. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = simpler data fetching, less client JS |
| Runtime | Node.js 20+ | `next dev` requires 18+; 20 has stable fetch, built-in test runner |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead. Use Turso only if you need multi-region |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, excellent migrations. No Prisma (see Anti-Patterns) |
| Auth | Lucia + `oslo` | Session-based, works with SQLite out of the box. No JWT in cookies |
| Styling | Tailwind CSS 3.4 | Utility-first, no runtime CSS-in-JS overhead |
| Components | shadcn/ui | Copy-pasteable, Radix-based, no npm dependency hell |
| Validation | Zod | Same schemas for API, forms, and DB |
| Testing | Vitest + Playwright | Unit + E2E. `next test` is not stable enough |

**Lockfile:** `pnpm-lock.yaml` only. No `package-lock.json` or `yarn.lock`.

---

## Folder Structure

