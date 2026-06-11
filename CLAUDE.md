# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your repo root and Claude will understand your stack without asking questions.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, stable since 15.1 |
| Runtime | Node.js 20+ | `crypto.randomUUID` native, stable ESM, long-term support |
| Database | `better-sqlite3` | Synchronous, fast, zero network latency, perfect for single-node SaaS |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly |
| Auth | Lucia (or custom session) | Session cookies, no JWT in localStorage, works with SQLite |
| Styling | Tailwind CSS 4 + shadcn/ui | Utility-first, component primitives, no CSS-in-JS runtime cost |
| Validation | Zod | Schema validation shared between server and client |
| Testing | Vitest + Playwright | Unit tests in Node, E2E in real browser |

**Non-negotiable:** We do not use Prisma (slow, heavy) or Turso (network latency defeats SQLite's purpose for single-node). If we outgrow single-node, we migrate to Postgres, not Turso.

---

## Folder Structure

