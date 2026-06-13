# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Every rule below exists because we made the mistake so you don't have to.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, simpler data flow |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `node:sqlite` if we ever need it |
| Database | `better-sqlite3` | Synchronous, fast, zero connection pooling complexity for single-node deploys |
| ORM/Query | Raw SQL + `better-sqlite3` | ORMs hide performance footguns; we write SQL to know our queries |
| Migrations | Custom Node.js scripts | One less dependency to break; SQL is the source of truth |
| Auth | `iron-session` + bcrypt | Stateless sessions, no Redis/DB session table needed |
| Styling | Tailwind CSS 3.4+ | Utility-first, zero runtime, design system via config |
| Forms | Server Actions + `useFormState` | No API routes for mutations; colocate logic with components |
| Validation | Zod | Same schemas on server and (optional) client |
| Testing | Vitest + Playwright | Unit for logic, E2E for critical paths |

**Lockfile rule:** `package-lock.json` is committed. `npm ci` in CI, never `npm install`.

---

## Folder Structure

