# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Copy this file to your project root. Claude Code reads it automatically for context.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | `better-sqlite3` requires native bindings; Edge runtime breaks this |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead. Use Turso only if you need multi-region |
| ORM / Query Builder | Drizzle ORM | Type-safe SQL, lightweight, migration-first, works with `better-sqlite3` |
| Auth | Lucia + `oslo` | Session-based, works in Server Components, no JWT in cookies |
| Styling | Tailwind CSS + `cn()` (clsx + tailwind-merge) | Utility-first, no runtime CSS-in-JS |
| Forms | Server Actions + `zod` | No API routes for mutations; validate on the server |
| Date handling | `date-fns` | Immutable, tree-shakeable, no timezone footguns like Moment |

**Hard rule:** Do not use the Edge runtime. `better-sqlite3` is synchronous and native. Deploy on a Node.js host (Railway, Fly.io, VPS).

---

## Folder Structure

