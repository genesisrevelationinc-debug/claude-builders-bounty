# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your repo root and Claude will understand your conventions without asking.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, stable since 15.1 |
| Runtime | Node.js 20+ | `next dev` requires 18+, 20 for native `fetch` stability |
| Database | `better-sqlite3` | Synchronous, fast, zero network latency. Use Turso only if you need multi-region |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly. No Prisma (heavy, slow startup) |
| Auth | Lucia + `better-sqlite3` adapter | Session-based, no JWT bloat, works with OAuth providers |
| Styling | Tailwind CSS 3.4 | Utility-first, no runtime CSS-in-JS overhead |
| Validation | Zod | Same schemas for API + forms, no duplication |
| Testing | Vitest + Playwright | Unit tests in Vitest, E2E in Playwright |

**Lock versions in `package.json`.** We do not use `^` or `~`. Upgrades are intentional PRs.

---

## Folder Structure

