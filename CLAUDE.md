# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read before writing code. Claude: use this as ground truth.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server-first, streaming, stable |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable ESM |
| Database | `better-sqlite3` | Synchronous, fast, zero network latency for single-tenant |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly |
| Auth | Lucia + `oslo` | Session cookies, no JWT in browser, works with SQLite |
| Styling | Tailwind CSS + `cn()` | Utility-first, no runtime CSS-in-JS overhead |
| Forms | Server Actions + `zod` | No API boilerplate, end-to-end type safety |
| Validation | `zod` | Single source of truth, shareable schema |

**Non-negotiable:** We do not use Prisma (heavy binary, slow in serverless), tRPC (overkill with Server Actions), or JWT in localStorage (XSS vector).

---

## Folder Structure

