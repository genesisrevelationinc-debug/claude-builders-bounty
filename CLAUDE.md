# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your repo root and Claude will understand your conventions without asking.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, stable |
| Runtime | Node.js 20+ | LTS, native `fetch`, `crypto` |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Drizzle ORM | Type-safe SQL, migrations, no hidden queries |
| Auth | Lucia + `oslo` | Session-based, works with SQLite, no external deps |
| Styling | Tailwind CSS 3.4 + shadcn/ui | Utility-first, accessible primitives |
| Validation | Zod | Same schemas for client, server, and DB |
| Testing | Vitest + Playwright | Unit + E2E, fast |

**Non-negotiable:** We do not use Prisma (slow startup, opaque query engine), Mongoose (wrong database), or Supabase (adds network latency for SQLite).

---

## Folder Structure

