# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS |
| Runtime | Node.js 20+ | `crypto.randomUUID` native, stable fetch |
| Database | `better-sqlite3` | Synchronous, fast, no connection pool complexity for single-node deploys |
| Migrations | Custom SQL scripts | No ORM migration lock-in; SQL is the source of truth |
| Auth | Lucia (or custom session) | Lightweight, no OAuth bloat unless needed |
| Styling | Tailwind CSS + CSS variables | No runtime CSS, consistent design tokens |
| Forms | Server Actions + `useFormState` | No API routes for mutations; progressive enhancement |
| Validation | Zod | Type-safe, works with Server Actions |
| Testing | Vitest + Playwright | Unit + E2E, no Jest config hell |

**Non-negotiable:** SQLite in WAL mode. Always. It enables concurrent reads during writes.

---

## Folder Structure

