# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS |
| Runtime | Node.js 20+ | `crypto` global, native fetch, stable |
| Database | `better-sqlite3` | Synchronous, fast, no connection pool hell |
| ORM/Query | Raw SQL + `better-sqlite3` | ORMs hide performance cliffs; SQL is the API |
| Migrations | Custom Node.js scripts | Zero deps, full control, runs in CI |
| Auth | `iron-session` + bcrypt | Stateless, no Redis/DB session table needed |
| Styling | Tailwind CSS 3.4+ | Utility-first, no runtime CSS |
| Forms | Server Actions + `useFormState` | No API routes for mutations |
| Validation | Zod | Same schemas on server + client |
| Testing | Vitest + Playwright | Unit + E2E, no Jest |

**Lock these versions.** Do not upgrade major versions without a migration plan.

---

## Folder Structure

