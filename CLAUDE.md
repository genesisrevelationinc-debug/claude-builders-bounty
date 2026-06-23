# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your repo root.
> Assumes: Next.js 15 App Router, TypeScript, Tailwind CSS, better-sqlite3 (or Turso), shadcn/ui.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, simpler data fetching |
| Language | TypeScript 5.x | Strict mode. No `any` without comment explaining why |
| Styling | Tailwind CSS 3.4+ | Utility-first, no CSS-in-JS runtime cost |
| Components | shadcn/ui | Copy-paste components, full control, no version lock-in |
| Database | better-sqlite3 (dev) / Turso (prod) | Single file, zero-config local dev; libsql for edge |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly |
| Auth | Lucia + oslo (or NextAuth.js v5) | Session-based, works edge + Node, no vendor lock |
| Validation | Zod | Runtime validation mirrors TS types |
| Testing | Vitest + Playwright | Unit: Vitest (fast). E2E: Playwright (real browser) |

**Node version:** `>=20.0.0` (LTS). We use `fetch` globally, `structuredClone`, and `crypto` without polyfills.

---

## Folder Structure

