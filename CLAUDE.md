# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated conventions for building a production SaaS with Next.js 15 App Router and SQLite.
> Every rule below exists because we made the mistake so you don't have to.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, simpler data flow |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `AsyncLocalStorage` |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead. Use Turso only if you need multi-region |
| ORM/Query | Raw SQL + `better-sqlite3` | ORMs hide performance footguns; we write SQL to feel the schema |
| Migrations | Custom Node.js scripts | `node-pg-migrate` et al are overkill for SQLite. One file per migration, run in order |
| Auth | `iron-session` or `jose` + bcrypt | No NextAuth — we own the session table, no magic, no vendor lock |
| Styling | Tailwind CSS + CSS variables | Utility-first + theming without JS runtime |
| Forms | Server Actions + `useActionState` | No `react-hook-form` for simple cases — Server Actions validate on the server |
| Validation | Zod | Schema shared between Server Actions and API routes |

**Lock these versions.** Do not upgrade major versions without a migration plan.

---

## Folder Structure

