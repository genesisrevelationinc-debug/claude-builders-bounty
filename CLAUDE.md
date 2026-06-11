# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code.  
> Last updated: 2026-03-01

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS |
| Runtime | Node.js 20+ | `fetch` cache controls, native `crypto` |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly |
| Auth | Lucia + `better-sqlite3` adapter | Minimal, session-based, no JWT bloat |
| Styling | Tailwind CSS + shadcn/ui | Utility-first, accessible primitives |
| Forms | Server Actions + `zod` | No API routes needed, validated at the edge |
| Testing | Vitest + Playwright | Unit + E2E without Jest config hell |

**Pinned versions** (do not upgrade without team discussion):
- `next@^15.0iru.0`
- `better-sqlite3@^9.0.0`
- `drizzle-orm@^0.30.0`
- `lucia@^3.0.0`

---

## Folder Structure

