# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your repo root.
> Assumes: Next.js 15 App Router, TypeScript, Tailwind CSS, better-sqlite3 (or Turso), tRPC or Server Actions.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Language | TypeScript 5.5+ | Strict mode. No `any` without comment justification |
| Styling | Tailwind CSS 3.4+ | Utility-first, zero runtime, design system via tokens |
| Database | better-sqlite3 (dev) / Turso (prod) | Single file, zero-config local dev; edge-ready with Turso |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly |
| Auth | Lucia (or NextAuth v5) | Session-based, works edge + Node, no vendor lock-in |
| Validation | Zod | Schema validation shared client/server |
| Testing | Vitest + Playwright | Unit: Vitest. E2E: Playwright. No Jest. |

**Node version:** `>=20.11.0` (LTS). Enforce via `engines` in `package.json`.

---

## Folder Structure

