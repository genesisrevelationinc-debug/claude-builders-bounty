# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a greenfield SaaS built with Next.js 15 App Router and SQLite.
> Paste this file at the root of your project. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Rationale |
|-------|--------|-----------|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `AsyncLocalStorage` |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Raw SQL via `better-sqlite3` + handwritten migrations | ORMs hide performance cliffs; SQL is the API you already know |
| Auth | `bcryptjs` + `jose` (JWT) | No external auth service dependency; works offline |
| Styling | Tailwind CSS 3.4+ | Utility-first, zero runtime, design system via config |
| Forms | Native + Server Actions | No client form libraries; `useActionState` for async feedback |
| Validation | `zod` | Share schemas between Server Actions and API routes |
| Testing | Vitest (unit) + Playwright (E2E) | Fast feedback + real browser coverage |

**Non-negotiable:** We do not use Turso, Prisma, or any other abstraction over SQLite. The point of SQLite is simplicity; adding a network layer or codegen step defeats it.

---

## Folder Structure

