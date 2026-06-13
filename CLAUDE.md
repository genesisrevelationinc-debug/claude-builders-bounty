# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated conventions for a production SaaS built with Next.js 15 App Router and SQLite.
> Paste this into your project root. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, simpler data fetching |
| Runtime | Node.js 20+ | `crypto` global, native fetch, stable |
| Database | `better-sqlite3` | Synchronous, fast, no connection pool complexity for single-node deploys |
| ORM/Query | Raw SQL + `better-sqlite3` | SQLite is simple; ORMs add indirection without benefit at this scale |
| Migrations | Custom Node.js scripts | `better-sqlite3` + `.sql` files. No third-party migrator needed |
| Auth | `iron-session` + bcrypt | Stateless sessions, no Redis/DB session table needed |
| Styling | Tailwind CSS 3.4+ | Utility-first, no runtime CSS-in-JS overhead |
| Forms | Server Actions + `useFormState` | No `react-hook-form` for simple cases; Server Actions handle validation |
| Validation | Zod | Share schemas between Server Actions and client |
| Testing | Vitest + Playwright | Unit for logic, E2E for critical paths |

**Non-negotiable:** We do not use `turso` or `@libsql/client`. This template targets single-node or self-hosted SQLite. If you need distributed SQLite, fork and modify.

---

## Folder Structure

