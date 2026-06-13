# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code. Every rule has a reason.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, simpler data fetching |
| Runtime | Node.js 20+ | `next/after`, stable `fetch`, native `crypto` |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Raw SQL + `drizzle-orm` | Type-safe queries without the weight of Prisma; schema in code |
| Auth | `oslo` + `bcryptjs` | Minimal, no external auth service dependency |
| Styling | Tailwind CSS 3.4 | Utility-first, no runtime CSS-in-JS overhead |
| Forms | Server Actions + `zod` | No API routes to maintain; validation co-located with action |
| Testing | Vitest + Playwright | Unit tests run fast; E2E catches integration bugs |

**Lock these versions.** Do not upgrade major versions without updating this file.

---

## Folder Structure

