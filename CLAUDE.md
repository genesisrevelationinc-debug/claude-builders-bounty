# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your repo root.
> Assumes: Next.js 15 App Router, TypeScript, Tailwind CSS, better-sqlite3 (or Turso), tRPC or Server Actions.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS |
| Runtime | Node.js 20+ | `crypto` global, native fetch, stable |
| Language | TypeScript 5.5+ | `strict: true` non-negotiable |
| Styling | Tailwind CSS 3.4+ | Utility-first, no runtime CSS-in-JS |
| Database | better-sqlite3 (dev) / Turso (prod) | Single file, zero-config, runs anywhere |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly |
| Auth | Lucia + oslo | Session-based, works with SQLite, no OAuth lock-in |
| Validation | Zod | Same schemas for API + forms |
| Testing | Vitest + Playwright | Unit + E2E, fast, native TS |

**Lock these versions.** Do not upgrade major versions without a migration plan.

---

## Folder Structure

