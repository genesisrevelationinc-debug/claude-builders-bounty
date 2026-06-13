# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Paste this file at the root of your project. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Lock Version |
|-------|--------|--------------|
| Framework | Next.js 15 | `next@15.x` |
| Runtime | Node.js 20+ | `.nvmrc` enforces this |
| Router | App Router | Pages Router is not used |
| Language | TypeScript 5.5+ | Strict mode enabled |
| Database | SQLite | `better-sqlite3` for local, `@libsql/client` for Turso |
| ORM | Drizzle ORM | Do not use Prisma (see Anti-patterns) |
| Auth | Lucia + Oslo | Or NextAuth.js v5 if OAuth is primary |
| Styling | Tailwind CSS 3.4+ | No CSS-in-JS libraries |
| UI Components | shadcn/ui | Install via CLI, do not hand-roll |
| Validation | Zod | For all runtime validation |
| Testing | Vitest + Playwright | Unit + E2E split |

**Why this stack:** SQLite eliminates infrastructure overhead for 0-10k users. better-sqlite3 is synchronous and fast for local dev. Turso provides global edge replication when you need it. Drizzle ORM generates type-safe SQL without a black-box query engine.

---

## Folder Structure

