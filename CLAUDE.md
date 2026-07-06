# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your repo root and Claude will understand your conventions without asking questions.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, stable since 15 |
| Runtime | Node.js 20+ | `next dev` requires 18+, 20 is current LTS |
| Database | better-sqlite3 | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly |
| Auth | Lucia + oslo | Session-based, works with SQLite, no OAuth lock-in |
| Styling | Tailwind CSS + shadcn/ui | Utility-first, accessible primitives, easy to eject |
| Validation | Zod | Same schemas for API, forms, and DB |
| Testing | Vitest + Playwright | Unit + E2E, fast, native Vite integration |

**Non-negotiable:** We do not use Prisma (heavy, slow on SQLite), tRPC (unnecessary with Server Actions), or NextAuth.js (bloated for our needs).

---

## Folder Structure

