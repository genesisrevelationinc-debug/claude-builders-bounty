# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Paste this file at the root of your project. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | `next` CLI requires 18+, 20+ for stable fetch/streams |
| Database | `better-sqlite3` | Synchronous, fast, zero-config for single-node deploys. Use `libsql` client only if you need Turso/edge |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly |
| Auth | Lucia + `better-sqlite3` adapter | Session-based, works without edge, no JWT in cookies |
| Styling | Tailwind CSS + shadcn/ui | Utility-first, accessible primitives, copy-paste components |
| Validation | Zod | Same schemas for API, forms, and DB |
| Testing | Vitest + Playwright | Unit tests for utilities, E2E for critical flows |

**Lock these versions in `package.json`. Do not upgrade major versions without a migration plan.**

---

## Folder Structure

