# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS |
| Runtime | Node.js 20+ | `crypto` global, native fetch, stable |
| Database | `better-sqlite3` | Synchronous, fast, no connection pool hell |
| ORM/Query | Raw SQL + `better-sqlite3` | ORMs hide performance footguns in SQLite |
| Auth | `bcryptjs` + `jose` (JWT) | No deps on platform-specific auth services |
| Styling | Tailwind CSS + CSS variables | Design tokens in CSS, not JS |
| Forms | Server Actions + `useActionState` | No API routes for CRUD |
| Validation | `zod` | Single source of truth, shareable |
| Testing | Vitest + Playwright | Unit + E2E, no Jest config drama |

**Non-negotiable:** We use the App Router. Pages Router code is rejected.

---

## Folder Structure

