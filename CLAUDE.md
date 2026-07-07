# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated conventions for building a production SaaS with Next.js 15 App Router and SQLite.
> Paste this into your project root. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, built on React 19 |
| Runtime | Node.js 20+ | Required for `crypto` global, `fetch` stability, and native `sqlite` module support |
| Database | `better-sqlite3` | Synchronous, fast augmented queries, no connection pool complexity for single-node deploys |
| ORM/Query | Raw SQL + `better-sqlite3` | SQLite is simple; ORMs add indirection without benefit. Use typed wrappers instead |
| Auth | `oslo` + `bcryptjs` | Stateless sessions in httpOnly cookies, no external auth provider dependency |
| Styling | Tailwind CSS 4 | Utility-first, zero runtime, works with Server Components |
| Forms | Server Actions + `zod` | No API routes needed; validation co-located with action |
| Testing | Vitest + `@testing-library/react` | Fast, ESM-native, matches Next.js toolchain |

**Non-negotiable:** We do not use `turso` or any remote SQLite. SQLite is local-first or we use Postgres. Remote SQLite is a category error.

---

## Folder Structure

