# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your repo root.
> Assumes: Next.js 15 App Router, TypeScript, Tailwind CSS, better-sqlite3 or Turso, tRPC or Server Actions.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | RSC, streaming, edge-ready. Pages Router is dead to us. |
| Language | TypeScript 5.x | Strict mode. No `any` without a `@ts-expect-error` comment. |
| Styling | Tailwind CSS 3.4+ | Utility-first. No CSS-in-JS (breaks RSC). |
| Database | better-sqlite3 (dev) / Turso (prod) | SQLite is enough until 100k users. Zero-config local dev. |
| ORM/Query | Drizzle ORM | Type-safe SQL. Prisma is too heavy for SQLite. |
| Auth | Lucia + oslo | Lightweight, session-based. No JWT in cookies. |
| Validation | Zod | Every API boundary, every form, every env var. |
| Testing | Vitest + Playwright | Unit in Vitest, E2E in Playwright. No Jest. |

**Node.js requirement:** `>=20.0.0` (for `crypto` global, native fetch, `structuredClone`).

---

## Folder Structure

