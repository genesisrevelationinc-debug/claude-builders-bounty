# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your repo root and Claude will understand how to work with your stack without asking questions.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `sqlite` module |
| Database | `better-sqlite3` | Synchronous, fast, zero-config for single-tenant SaaS |
| ORM / Query Builder | Drizzle ORM | Type-safe SQL, lightweight, great migration story |
| Auth | NextAuth.js v5 (Auth.js) | Edge-compatible, JWT sessions, OAuth providers |
| Styling | Tailwind CSS + shadcn/ui | Utility-first, accessible primitives, copy-paste components |
| Validation | Zod | Same schemas for API, forms, and DB |
| Testing | Vitest + Playwright | Unit tests in Node, E2E in real browser |

**Non-negotiable:** We do NOT use Turso/libSQL. This is a single- SaaS; `better-sqlite3` on the same server is faster and simpler. If we ever need multi-region, we'll migrate to Postgres—not a wrapper around SQLite.

---

## Folder Structure

