# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your repo root.
> Assumes: Next.js 15 App Router, TypeScript, Tailwind, better-sqlite3 or Turso, tRPC or Server Actions.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | `next dev` requires Node 18+; we pin to 20 for LTS stability |
| Language | TypeScript 5.5+ | Strict mode, `noUncheckedIndexedAccess` |
| Styling | Tailwind CSS 3.4+ | Utility-first, zero runtime, design system via tokens |
| Database | SQLite (better-sqlite3) or Turso | Single file / edge-distributed, no ORM overhead |
| Query Builder | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly |
| Auth | Lucia + oslo (or NextAuth.js v5) | Session-based, works with SQLite, no vendor lock-in |
| Validation | Zod | Same schemas for API, forms, and DB |
| Testing | Vitest + Playwright | Unit + E2E, fast, same config |

**Non-negotiable:** We do not use `next/image` for user-uploaded content (use signed R2/S3 URLs). We do not use Prisma (too heavy for SQLite).

---

## Folder Structure

