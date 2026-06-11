# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Paste this file at your repo root. Claude Code reads it automatically for context.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `AsyncLocalStorage` |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead, perfect for single-tenant or small multi-tenant SaaS |
| ORM / Query Builder | Drizzle ORM | Type-safe SQL, lightweight, excellent migration tooling |
| Auth | Lucia (or custom session with `iron-session`) | Session-based, no JWT complexity, works with SQLite natively |
| Styling | Tailwind CSS 3.4+ | Utility-first, minimal bundle, no runtime CSS-in-JS overhead |
| Forms | Server Actions + `zod` | No API boilerplate, progressive enhancement, type-safe validation |
| Testing | Vitest + Playwright | Unit tests with Node-compatible runner, E2E with real browser |

**Lockfile rule:** Use `pnpm`. Commit `pnpm-lock.yaml`. No `package-lock.json` or `yarn.lock` in repo.

---

## Folder Structure

