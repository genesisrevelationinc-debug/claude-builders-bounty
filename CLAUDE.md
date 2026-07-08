# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = simpler data flow |
| Runtime | Node.js 20+ | `crypto.randomUUID`, native `fetch`, stable `sqlite` |
| Database | `better-sqlite3` | Synchronous, fast, zero connection pooling complexity |
| ORM/Query | Raw SQL + `zod` | ORMs hide N+1s; Zod gives us type safety from the DB up |
| Auth | `lucia` + `oslo` | Lightweight, session-based, works without OAuth complexity |
| Styling | Tailwind CSS | Utility-first, no runtime CSS-in-JS overhead |
| Forms | Server Actions + `zod` | No API routes needed, validation co-located with mutation |
| Testing | Vitest + Playwright | Unit for logic, E2E for critical paths |

**Pinned versions** (do not upgrade without team discussion):
- `next`: `^15.0.0`
- `better-sqlite3`: `^11.0.0`
- `zod`: `^3.23.0`

---

## Folder Structure

