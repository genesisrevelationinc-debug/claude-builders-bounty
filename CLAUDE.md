# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Paste this into your project root. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `AsyncLocalStorage` |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Raw SQL + `zod` | No ORM magic. Explicit schemas. Faster than Prisma for SQLite |
| Auth | `bcryptjs` + `jose` (JWT) | No external auth service dependency. Self-contained |
| Styling | Tailwind CSS 3.4+ | Utility-first, no runtime CSS-in-JS overhead |
| Forms | Server Actions + `zod` | No API routes needed. Type-safe from form to DB |
| Testing | Vitest + Playwright | Unit tests for logic, E2E for critical paths |

**Lock these versions in `package.json`. Do not upgrade major versions without a migration plan.**

---

## Folder Structure

