# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Read this first. Follow it exactly. Ask before overriding.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | `fetch` cache control, native `crypto`, stable `sqlite` |
| Database | `better-sqlite3` | Synchronous, fast, zero-config for single-tenant deploys |
| ORM/Query | Raw SQL + `better-sqlite3` | No abstraction tax; schema is the source of truth |
| Migrations | Custom Node.js scripts | One `.sql` file per migration; runs in dependency order |
| Auth | `iron-session` + bcrypt | Stateless sessions, no external auth service dependency |
| Styling | Tailwind CSS + `cn()` utility | No CSS-in-JS runtime; deterministic class merging |
| Forms | Server Actions + `useFormState` | No client-side form libraries; validate on server |
| Testing | Vitest + Playwright | Unit tests for utilities; E2E for critical flows |

**Non-negotiable:** Do not add Prisma, Drizzle, or TypeORM. The schema lives in `.sql` files. ORMs hide performance footguns and make migrations opaque.

---

## Folder Structure

