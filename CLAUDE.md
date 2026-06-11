# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite (better-sqlite3 or Turso). Read this before writing code. Every rule exists to prevent a specific class of bug or decision fatigue.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, simpler data fetching |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `node:` imports |
| Database | SQLite via `better-sqlite3` (local/dev) or Turso (prod/edge) | Single file, zero-config local dev; Turso for edge replication |
| ORM/Query | Raw SQL + `better-sqlite3` | ORMs hide migration complexity; SQL is explicit and debuggable |
| Auth | `lucia` or custom JWT + `bcryptjs` | Session cookies, HttpOnly, SameSite=strict. No localStorage tokens |
| Styling | Tailwind CSS + `shadcn/ui` | Utility-first, no runtime CSS, copy-paste components |
| Forms | Server Actions + `zod` | No API routes for mutations; validate at the edge |
| Testing | Vitest (unit) + Playwright (E2E) | Fast unit tests; real browser for critical paths |

**Lockfile rule:** `package-lock.json` is source of truth. Never commit `yarn.lock` or `pnpm-lock.yaml`.

---

## Folder Structure

