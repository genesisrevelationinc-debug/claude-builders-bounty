# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite (better-sqlite3 or Turso).
> 
> **Rule of thumb:** If a convention isn't listed here, it doesn't exist. Ask before inventing.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `AsyncLocalStorage` |
| Database | SQLite via `better-sqlite3` (local) or `@libsql/client` (Turso/edge) | Single file, zero-config, works at the edge |
| Schema/Migrations | `drizzle-orm` + `drizzle-kit` | Type-safe SQL, zero runtime overhead, git-tracked migrations |
| Auth | `lucia` or `next-auth` v5 beta | Session-based, no JWT in localStorage |
| Styling | Tailwind CSS 3.4+ | Utility-first, no CSS-in-JS runtime |
| Forms | Server Actions + `react-hook-form` (client validation only) | Progressive enhancement, no API routes for CRUD |
| Testing | Vitest (unit), Playwright (E2E) | Fast, native ESM, same browser engine as users |

**Hard constraint:** No Docker, no Postgres, no Redis in development. The entire app must `git clone && npm install && npm run dev` on a fresh machine.

---

## Folder Structure

