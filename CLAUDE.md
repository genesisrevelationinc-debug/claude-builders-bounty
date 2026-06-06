# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code. If a rule seems arbitrary, it has a reason — usually a bug we hit in production.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, faster TTFB |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `AsyncLocalStorage` |
| Database | `better-sqlite3` | Synchronous, fast, no connection pool complexity for single-node deploys |
| ORM/Query | Raw SQL + `better-sqlite3` | ORMs hide performance cliffs; we own our SQL |
| Migrations | Custom Node.js scripts | Zero dependencies, full control, runs in CI in <100ms |
| Auth | `iron-session` + bcrypt | Stateless sessions, no Redis/DB session table needed |
| Styling | Tailwind CSS + CSS variables | No CSS-in-JS runtime cost; theming via `:root` vars |
| Forms | Server Actions + `useFormState` | No API routes for mutations; progressive enhancement free |
| Validation | Zod | Same schemas on server and client; no drift |
| Testing | Vitest + Playwright | Unit tests for logic, E2E for critical flows |

**Hard rule:** No packages that add a runtime unless they save >50ms per request or eliminate a class of bugs.

---

## Folder Structure

