# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Paste this file at your project root. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, built on React 19 |
| Runtime | Node.js 20+ | `fetch` cache control, native `crypto`, stable `sqlite` module |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-tenant deploys |
| ORM / Query Builder | Drizzle ORM | Type-safe SQL, lightweight, excellent migration tooling |
| Auth | Lucia (or custom session) | Cookie-based sessions, works without external providers |
| Styling | Tailwind CSS 3.4+ | Utility-first, no runtime CSS-in-JS overhead |
| Forms | Server Actions + `react-hook-form` | Progressive enhancement, type-safe validation with Zod |
| Validation | Zod | Schema-first, works on both server and client |
| Testing | Vitest + Playwright | Unit tests for logic, E2E for critical flows |

**Lockfile rule:** Use `pnpm`. Commit `pnpm-lock.yaml`. No `package-lock.json`, no `yarn.lock`.

---

## Folder Structure

