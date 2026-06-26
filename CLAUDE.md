# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your project root.
> Assumes: Next.js 15 (App Router), React 19, TypeScript, Tailwind CSS, better-sqlite3 or Turso, tRPC or Server Actions.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | App Router is stable; Pages Router is legacy for new projects |
| Runtime | Node.js 20+ | `next dev` requires 18+; 20 is current LTS with native `fetch` |
| Language | TypeScript 5.5+ | Strict mode enabled; no `any` without comment |
| Styling | Tailwind CSS 3.4+ | Utility-first, zero runtime, design system via config |
| Database | better-sqlite3 (local) / Turso (prod) | SQLite is sufficient until 10k+ concurrent writes; zero infra overhead |
| ORM/Query | Drizzle ORM | Type-safe SQL; migrations are plain `.sql` files |
| Auth | Lucia (or NextAuth v5 beta) | Session-based, no JWT in localStorage. Prefer Lucia for SQLite-native |
| Validation | Zod | Share schemas between API and forms |
| Testing | Vitest + Playwright | Unit for logic, E2E for critical paths |

**Lock these versions.** Do not upgrade major versions without a migration plan.

---

## Folder Structure

