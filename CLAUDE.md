# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code.  
> Goal: eliminate decision fatigue, prevent common foot-guns, and keep the codebase maintainable at scale.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, simpler data flow |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable ESM |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Raw SQL + `better-sqlite3` | ORMs hide performance cliffs; SQL is explicit and portable |
| Migrations | Custom Node.js scripts | One `.sql` file per migration, run in order, no hidden magic |
| Styling | Tailwind CSS 3.4+ | Utility-first, no runtime CSS-in-JS overhead |
| Forms | Server Actions + `useFormState` | No API routes to maintain, progressive enhancement built-in |
| Auth | `bcryptjs` + `jose` (JWT) | No external auth service dependency, works at edge |
| Validation | `zod` | Single source of truth, infers TypeScript types |

> **Turso note:** If you switch to Turso (libSQL), wrap `better-sqlite3` calls in a thin adapter. The migration and query conventions here stay identical.

---

## Folder Structure

