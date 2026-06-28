# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> **Purpose:** Eliminate decision fatigue. Every rule below exists because we made the mistake so you don't have to.

---

## Stack & Versions

| Layer | Choice | Rationale |
|-------|--------|-----------|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, simpler data flow |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `node:` imports |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query Builder | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly |
| Auth | Lucia + `better-sqlite3` adapter | Session-based, no JWT bloat, works offline |
| Styling | Tailwind CSS 3.4+ | Utility-first, no runtime CSS-in-JS overhead |
| Forms | Server Actions + `react-hook-form` | Progressive enhancement, type-safe from server to client |
| Validation | Zod | Single source of truth for schemas |
| Testing | Vitest + Playwright | Unit tests fast, E2E tests catch integration bugs |

**Lock it:** Pin exact versions in `package.json`. No `^`, no `~`. Reproducible builds > minor updates.

---

## Folder Structure

