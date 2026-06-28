# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this at the root of any greenfield Next.js 15 + SQLite project. No clarifying questions should be needed.

---

## Stack & Versions

| Layer | Choice | Rationale |
|-------|--------|-----------|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, simpler data fetching |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `sqlite` support |
| Database | `better-sqlite3` | Synchronous, fast, zero connection pooling complexity for single-node deploys |
| ORM/Query | Raw SQL via `better-sqlite3` + handwritten migrations | ORMs hide performance cliffs; explicit SQL is maintainable at SaaS scale |
| Auth | `bcryptjs` + `jose` (JWT) | No third-party auth service dependency; works offline; portable |
| Styling | Tailwind CSS 3.4+ | Utility-first, zero runtime, team consistency |
| Forms | Server Actions + `zod` | No API routes needed; validation co-located with action |
| Testing | Vitest + `@testing-library/react` | Fast, ESM-native, same test runner for unit + component |

**Non-negotiable:** We do not use Prisma, Drizzle, or any query builder. Raw SQL with explicit types.

---

## Folder Structure

