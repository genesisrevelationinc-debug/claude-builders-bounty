# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your repo root.
> Assumes: greenfield project, single developer or small team, shipping fast.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, simpler data flow |
| Runtime | Node.js 20+ | `next dev` turbopack, native `fetch`, stable `crypto` |
| Database | better-sqlite3 | Synchronous, fast, zero network overhead. Use Turso only if you need multi-region |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly |
| Auth | Lucia (or custom session) | SQLite-native sessions, no external dependencies |
| Styling | Tailwind CSS + shadcn/ui | Copy-paste components, no version drift |
| Validation | Zod | Same schemas for API, forms, and DB |
| Testing | Vitest + Playwright | Unit + E2E without Jest config hell |

**Lock these versions.** Do not upgrade major versions without a migration plan.

---

## Folder Structure

