# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Paste this file at the root of your project. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | `next dev` requires Node 18+; we target 20 for LTS |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Raw SQL + custom migration runner | ORMs hide performance cliffs; SQL is explicit and portable |
| Auth | `bcryptjs` + `jose` (JWT) | No external auth service dependency; works offline |
| Styling | Tailwind CSS 3.4+ | Utility-first, minimal CSS bundle, design system via config |
| Forms | Server Actions + `react-hook-form` | Server Actions for mutations; RHF for complex client validation |
| Testing | Vitest + Playwright | Unit tests in-memory SQLite; E2E against built app |

**Non-negotiable:** `strict: true` in `tsconfig.json`. No `any` without a `// @reason` comment.

---

## Folder Structure

