# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS |
| Runtime | Node.js 20+ | `crypto` global, native fetch, stable |
| Database | `better-sqlite3` | Synchronous, fast, no connection pool hell |
| ORM/Query | Raw SQL + `better-sqlite3` | ORMs hide performance cliffs; SQL is portable |
| Auth | `oslo` + `bcryptjs` | No vendor lock-in, works with any user table |
| Styling | Tailwind CSS 3.4+ | Utility-first, no runtime CSS-in-JS overhead |
| Forms | Server Actions + `zod` | No API routes needed for mutations |
| Validation | `zod` | Single source of truth, shared client/server |

**Non-negotiable:** We do NOT use Prisma, Drizzle, or any query builder. Raw SQL with typed wrappers only.

---

## Folder Structure

