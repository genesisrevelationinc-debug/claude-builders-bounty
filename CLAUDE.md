# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, stable |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable ESM |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Raw SQL + `better-sqlite3` | No ORM magic. Explicit queries are debuggable and performant |
| Migrations | Custom Node.js scripts | One `.sql` file per migration, run in order |
| Styling | Tailwind CSS 3.4+ | Utility-first, no runtime CSS-in-JS overhead |
| Forms | Server Actions + `useFormState` | No API routes for mutations. Progressive enhancement built-in |
| Auth | `iron-session` or `jose` + bcrypt | Stateless sessions, no external auth service dependency |
| Validation | `zod` | Schema reuse between Server Actions and client |

**Non-negotiable:** We do not use `prisma`, `drizzle`, or `knex`. They add abstraction layers that obscure SQL and complicate the SQLite build step.

---

## Folder Structure

