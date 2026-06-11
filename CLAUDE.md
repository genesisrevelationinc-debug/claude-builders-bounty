# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Paste this file at the root of your project. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, built on React 19 |
| Runtime | Node.js 20+ | Required for `next` CLI and native modules |
| Database | `better-sqlite3` | Synchronous, fast, zero-config for single-tenant or small multi-tenant apps. Use Turso only if you need edge replication |
| ORM/Query Builder | Drizzle ORM | Type-safe SQL, lightweight, excellent migrations, no hidden queries |
| Auth | `bcryptjs` + `jose` (JWT) | No vendor lock-in. Roll your own or use Clerk if you need SSO/SAML |
| Styling | Tailwind CSS 3.4+ | Utility-first, no runtime CSS, works with Server Components |
| Forms | `react-hook-form` + `zod` | Type-safe validation, works without JS (progressive enhancement) |
| Date/Time | `date-fns` | Tree-shakeable, no mutable globals like Moment |

**Hard rule:** Do not add a new dependency without documenting why it beats a built-in or existing choice in this file.

---

## Folder Structure

