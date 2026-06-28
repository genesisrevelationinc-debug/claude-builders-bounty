# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your repo root.
> Assumes: Next.js 15 App Router, TypeScript, Tailwind, better-sqlite3 (or Turso), tRPC or Server Actions.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, simpler data flow |
| Language | TypeScript 5.x | Strict mode. No `any` without comment explaining why |
| Styling | Tailwind CSS 3.4+ | Utility-first, no runtime CSS-in-JS overhead |
| Database | better-sqlite3 (dev) / Turso (prod) | SQLite is enough until 10k+ concurrent writes. Zero-config local dev |
| ORM/Query | Drizzle ORM | Type-safe SQL. Migrations are plain SQL files, not black boxes |
| Auth | Lucia + oslo (or NextAuth v5) | Session-based, works edgeless, no vendor lock-in |
| Validation | Zod | Same schemas on server and client. Single source of truth |
| Testing | Vitest + Playwright | Unit for logic, E2E for critical paths |

**Node version:** `>=20.11.0` (LTS). We use `--experimental-sqlite` only in scripts, never in app code.

---

## Folder Structure

