# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production SaaS built with Next.js 15 App Router and SQLite.
> Paste this into your repo root. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, faster TTFB |
| Runtime | Node.js 20+ | `fetch` cache, native `crypto`, stable ESM |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM / Query Builder | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly |
| Auth | Lucia + `oslo` | Session-based, works without OAuth providers, SQLite-native |
| Styling | Tailwind CSS 3.4 + `cn()` | Utility-first, no runtime CSS-in-JS overhead |
| Forms | Server Actions + `zod` | No API routes needed, validation co-located with action |
| Testing | Vitest + Playwright | Unit tests in-memory SQLite, E2E on real build |

**Non-negotiable:** We do not use Prisma. The query engine binary adds 45MB+ to Docker images and startup time matters for serverless cold starts.

---

## Folder Structure

