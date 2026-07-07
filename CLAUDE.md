# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production SaaS built with Next.js 15 App Router and SQLite (better-sqlite3 or Turso). Read this before writing code. Claude uses this as ground truth.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, simpler data flow |
| Runtime | Node.js 20+ | `crypto` global, native fetch, stable |
| Database | better-sqlite3 (local) / Turso (prod) | Same libsql wire protocol, trivial to switch |
| ORM/Query | Drizzle ORM | Type-safe SQL, migrations in TypeScript, no query builder lock-in |
| Auth | Lucia (or custom session) | Lightweight, no vendor lock-in, works with SQLite natively |
| Styling | Tailwind CSS + shadcn/ui | Utility-first, copy-paste components, no runtime CSS-in-JS |
| Validation | Zod | Same schemas for API, forms, and DB |
| Testing | Vitest + Playwright | Unit tests in Node, E2E in real browser |

**Hard rule:** No version pinning with `^`. Use exact versions in `package.json` to prevent "works on my machine" drift. Renovate handles bumps.

---

## Folder Structure

