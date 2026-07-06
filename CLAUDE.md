# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your repo root. Claude reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, stable |
| Runtime | Node.js 20+ | `next` requires it; use `process.version` to verify |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Raw SQL + `better-sqlite3` | ORMs hide migration complexity; we own the SQL |
| Migrations | Custom Node.js scripts | One `.sql` file per migration, run in order, wrapped in transactions |
| Auth | `bcryptjs` + `jose` (JWT) | No third-party auth service dependency; works offline |
| Styling | Tailwind CSS 3.4+ | Utility-first, no runtime CSS-in-JS overhead |
| Forms | Server Actions + `useFormState` | No API routes needed for mutations |
| Validation | `zod` | Share schemas between server and client |
| Testing | Vitest + `@testing-library/react` | Fast, ESM-native, no Jest config hell |

**Non-negotiable:** We do not use Prisma, Drizzle, or any query builder. Raw SQL is readable, debuggable, and has no hidden N+1 problems.

---

## Folder Structure

