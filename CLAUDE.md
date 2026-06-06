# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated conventions for a production SaaS built with Next.js 15 App Router and SQLite.
> Paste this into your project root. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | `next` requires 18+; 20 has stable `fetch` and `crypto` |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| Query Builder | `drizzle-orm` + `drizzle-kit` | Type-safe SQL, migrations, no query builder bloat |
| Auth | `next-auth` v5 (Auth.js) | Edge-compatible, JWT sessions, OAuth providers |
| Styling | Tailwind CSS + `shadcn/ui` | Utility-first, accessible primitives, copy-paste ownership |
| Validation | `zod` | Schema validation shared between server and client |
| Testing | Vitest + Playwright | Unit tests in-memory; E2E against real build |

**Lock these versions.** Do not upgrade major versions without a migration plan.

---

## Folder Structure

