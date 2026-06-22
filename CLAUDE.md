# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite (better-sqlite3 or Turso).

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | Native `fetch`, stable `crypto`, long-term support |
| Database | SQLite via `better-sqlite3` (local) or Turso (cloud) | Zero-config local dev, trivial to scale to edge |
| ORM / Query Builder | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly |
| Auth | Lucia + `oslo` (or NextAuth.js v5) | Session-based, works edge + Node, no vendor lock-in |
| Styling | Tailwind CSS + `shadcn/ui` | Utility-first, accessible primitives, copy-paste components |
| Validation | Zod | Single source of truth for schemas (API + forms) |
| Testing | Vitest + Playwright | Unit tests in Node, E2E in real browser |

**Pinned versions (lockfile is source of truth):**
