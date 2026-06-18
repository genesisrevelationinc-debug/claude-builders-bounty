# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your repo root and Claude will understand your conventions without asking.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, stable |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, `structuredClone` |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Raw SQL + `better-sqlite3` | No ORM bloat; SQL is the source of truth |
| Migrations | Custom Node.js scripts | `node scripts/migrate.js` — explicit, debuggable, no magic |
| Auth | `iron-session` + bcrypt | Stateless sessions, no Redis/DB session table needed |
| Styling | Tailwind CSS 3.4+ | Utility-first, no runtime CSS-in-JS overhead |
| Forms | Server Actions + `useFormState` | No API routes for mutations; progressive enhancement |
| Validation | `zod` | Single source of truth for server and client schemas |
| Testing | Vitest (unit) + Playwright (E2E) | Fast unit tests; real browser for critical flows |

**Non-negotiable:** We do not use `next-auth`, Prisma, or tRPC. They add indirection and lock-in that outpace their value for a SQLite-backed SaaS.

---

## Folder Structure

