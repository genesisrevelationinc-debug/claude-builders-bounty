# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your repo root.
> Assumes: Next.js 15 App Router, TypeScript, Tailwind CSS, better-sqlite3 or Turso, and a single developer or small team shipping fast.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, simpler data fetching |
| Language | TypeScript 5.x | Strict mode. No `any` without a comment explaining why |
| Styling | Tailwind CSS 3.4+ | Utility-first, no CSS-in-JS runtime cost |
| Database | better-sqlite3 (dev) / Turso (prod) | SQLite is enough until you have >10k concurrent writes. Zero config locally |
| ORM/Query | Drizzle ORM | Type-safe SQL. Migrations are plain SQL files. No hidden queries |
| Auth | Lucia + oslo | Session-based, works with SQLite out of the box. No JWT bloat |
| Validation | Zod | Share schemas between server and client where possible |
| Testing | Vitest + Playwright | Unit for logic, E2E for critical paths only |

**Node version:** `>=20.0.0` (LTS). Use `nvm` or `fnm` to pin.

---

## Folder Structure

