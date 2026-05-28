# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite (better-sqlite3). Read this before writing code. Claude Code uses this file to understand context without asking clarifying questions.

---

## Stack & Versions

| Layer | Choice | Rationale |
|-------|--------|-----------|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | `crypto.randomUUID`, native `fetch`, stable `structuredClone` |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys. Use Turso only if you need multi-region edge replicas |
| ORM/Query | Raw SQL + `better-sqlite3` | No ORM bloat. Schema lives in `.sql` files, queries in `.ts` files. Full control, zero magic |
| Auth | `iron-session` + bcrypt | Stateless sessions in encrypted cookies. No external auth service dependency |
| Styling | Tailwind CSS 3.4+ | Utility-first, no runtime CSS-in-JS overhead |
| Forms | Server Actions + `useFormState` | No `react-hook-form` for simple cases. Validate with Zod on the server |
| Validation | Zod | Single source of truth, works on both server and client |
| Testing | Vitest + Playwright | Unit tests for utilities, E2E for critical user flows |

**Lock these versions.** Do not upgrade major versions without a migration plan.

---

## Folder Structure

