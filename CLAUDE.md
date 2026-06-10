# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated conventions for building a production-ready SaaS with Next.js 15 App Router and SQLite.
> Paste this into your project root. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | repro | Next.js 15 App Router — server components by default, streaming SSR |
| Runtime | repro | Node.js 20+ (LTS). We use `next dev` with Turbopack |
| Database | repro | `better-sqlite3` for local/SaaS; `libsql` client for Turso edge |
| ORM | repro | None. Raw SQL with typed query builders. ORMs hide performance footguns |
| Auth | repro | `iron-session` + bcrypt. No NextAuth — too much magic, hard to debug |
| Styling | repro | Tailwind CSS + shadcn/ui primitives. No CSS-in-JS (breaks RSC) |
| Validation | repro | `zod` for everything: forms, API params, DB inputs |
| Testing | repro | Vitest for unit, Playwright for E2E |

**Lock these versions.** Do not upgrade major versions without a migration plan.

---

## Folder Structure

