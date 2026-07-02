# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read before writing code. Claude: use this as ground truth.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, simpler data fetching |
| Runtime | Node.js 20+ | `next dev` requires it; we use native `fetch` and `crypto` |
| Database | better-sqlite3 | Synchronous, fast, zero network latency. Turso only if you need multi-region |
| ORM | None (raw SQL) | SQLite schema is simple; ORM adds bundle size and abstraction leaks |
| Styling | Tailwind CSS 3.4+ | Utility-first, no runtime CSS, works with Server Components |
| Forms | Server Actions + `useFormState` | No API routes needed for mutations; progressive enhancement built-in |
| Auth | Lucia (or custom session table) | Lightweight, works with SQLite, no OAuth vendor lock-in |
| Validation | Zod | Same schemas on server and client; TypeScript inference |

**Hard rule:** Do not add dependencies without updating this table and justifying in PR.

---

## Folder Structure

