# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your repo root.
> Assumes: Next.js 15 App Router, TypeScript, Tailwind CSS, better-sqlite3 or Turso, shadcn/ui.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = simpler data flow |
| Runtime | Node.js 20+ | `next dev` requires 18+, 20 for stable fetch |
| Language | TypeScript 5.5+ | Strict mode, `noUncheckedIndexedAccess` |
| Database | better-sqlite3 (dev) / Turso (prod) | Single file, zero network latency, works on Edge |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, no codegen bloat |
| Auth | Lucia + oslo | Session-based, works with SQLite, no OAuth lock-in |
| Styling | Tailwind CSS 3.4+ | Utility-first, no runtime CSS |
| Components | shadcn/ui | Copy-paste, fully customizable, no npm dep |
| Validation | Zod | Same schemas for API + forms |
| Testing | Vitest + Playwright | Unit + E2E, fast |

**Non-negotiable:** We do NOT use Prisma. It downloads a 50MB engine and hides SQL. Drizzle lets you see and optimize every query.

---

## Folder Structure

