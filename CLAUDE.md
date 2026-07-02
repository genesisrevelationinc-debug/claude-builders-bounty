# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Paste this file at the root of your project. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, built on React 19 |
| Runtime | Node.js 20+ | Required for `crypto` global, native `fetch`, and `AsyncLocalStorage` |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead. Use Turso only if you need multi-region |
| ORM / Query Builder | Drizzle ORM | Type-safe SQL, lightweight, excellent migrations, no codegen bloat |
| Auth | Lucia + `oslo` | Session-based, works with SQLite out of the box, no third-party lock-in |
| Styling | Tailwind CSS 3.4 | Utility-first, minimal CSS bundle, works with Server Components |
| Forms | `react-hook-form` + `zod` | Client validation + Server Action validation with one schema |
| Payments | Stripe | Standard. Use `stripe` SDK in Server Actions only |

**Lockfile rule:** Use `pnpm`. Commit `pnpm-lock.yaml`. No `package-lock.json`, no `yarn.lock`.

---

## Folder Structure

