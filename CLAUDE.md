# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your repo root and Claude will understand your conventions without asking questions.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, stable |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable ESM |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly |
| Auth | Lucia (or custom session) | Cookie-based sessions, works with SQLite out of the box |
| Styling | Tailwind CSS + shadcn/ui | Utility-first, accessible primitives, no CSS-in-JS runtime |
| Validation | Zod | Same schemas for API, forms, and DB |
| Testing | Vitest + Playwright | Unit + E2E without Jest's baggage |

**Non-negotiable:** We do not use `next-auth` (too much magic, hard to debug) or Prisma (heavy binary, slow in serverless).

---

## Folder Structure

