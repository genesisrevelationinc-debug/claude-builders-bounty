# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read before generating code. Every rule has a reason.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, minimal client JS |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `structuredClone` |
| Database | `better-sqlite3` | Synchronous, fast, zero network latency, works on server |
| ORM/Query | Raw SQL + `better-sqlite3` | No ORM bloat; SQL is the source of truth, easy to optimize |
| Migrations | Custom Node.js scripts | One dependency fewer; full control over transaction boundaries |
| Auth | `bcryptjs` + `jose` (JWT) | No third-party auth service lock-in; works offline |
| Styling | Tailwind CSS 3.4 | Utility-first, no runtime CSS, tree-shakes dead styles |
| Forms | Server Actions + `zod` | No API routes to maintain; validation co-located with action |
| Testing | Vitest + `better-sqlite3` in-memory | Same DB in tests and production; no Docker required |

**Pinned versions** (do not upgrade without team discussion):
- `next`: `^15.0.0`
- `better-sqlite3`: `^11.0.0`
- `tailwindcss`: `^3.4.0`

---

## Folder Structure

