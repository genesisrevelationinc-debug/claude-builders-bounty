# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Paste this file at your repo root. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Lock Version |
|-------|--------|--------------|
| Framework | Next.js 15 | `next@^15.0.0` |
| Runtime | Node.js 20+ | `.nvmrc` enforced |
| Router | App Router | Pages Router is forbidden |
| Database | SQLite | `better-sqlite3@^11.0.0` |
| ORM / Query Builder | Drizzle ORM | `drizzle-orm@^0.30.0` + `drizzle-kit` |
| Migrations | Drizzle Kit | SQL-first, never manual |
| Auth | Lucia (or custom session) | Cookie-based, no JWT in localStorage |
| Styling | Tailwind CSS v4 | No CSS-in-JS |
| Components | shadcn/ui | Radix-based, client-opt-in |
| Validation | Zod | Shared schemas, server and client |
| Testing | Vitest + Playwright | Unit + E2E split |

**Why these versions:** Next.js 15 ships stable App Router with `dynamicIO` and `unstable_after`. SQLite keeps ops simple (single file, no Docker). Drizzle gives type-safe SQL without query builder bloat. Locking versions prevents "works on my machine."

---

## Folder Structure

