# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, built on React 19 |
| Runtime | Node.js 20+ | `next start` requires Node 18+; we target 20 for native `fetch` stability |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead. Use Turso only if you need multi-region |
| ORM/Query | Raw SQL via `better-sqlite3` + handwritten migrations | ORMs hide performance footguns in SQLite; explicit SQL is maintainable at SaaS scale |
| Auth | `bcryptjs` + `jose` (JWT) | No external auth service dependency; works offline, zero cold start |
| Styling | Tailwind CSS 3.4 | Utility-first, no runtime CSS, works with Server Components |
| Forms | Server Actions + `zod` | No client-side form libraries; validate on the server, revalidate with `useFormState` |
| Testing | Vitest (unit) + Playwright (E2E) | Jest is slow; Playwright matches real user behavior |

**Non-negotiable:** All database access happens in Server Components or Server Actions. No `fetch` to internal API routes.

---

## Folder Structure

