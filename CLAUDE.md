# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your repo root and Claude will understand your stack, conventions, and boundaries without asking.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | `fetch` cache controls, native `crypto`, stable |
| Database | `better-sqlite3` | Synchronous, fast, zero network latency, works in Server Components |
| ORM/Query | Raw SQL + `better-sqlite3` | No abstraction leak; SQLite is simple enough |
| Auth | `bcryptjs` + `jose` (JWT) | No `node:crypto` dependency issues, edge-compatible JWT |
| Styling | Tailwind CSS 3.4 | Utility-first, no runtime CSS-in-JS overhead |
| Forms | Server Actions + `useFormState` | Progressive enhancement, no API routes needed |
| Validation | `zod` | Type-safe, works on server and client |
| Testing | Vitest + `@testing-library/react` | Fast, ESM-native, no Jest config hell |

**Non-negotiable:** We do not use `turso` or any remote SQLite. The whole point of SQLite in this stack is zero network calls, zero connection pooling, and trivial local development. If we need multi-region later, we migrate to Postgres with `drizzle-orm`.

---

## Folder Structure

