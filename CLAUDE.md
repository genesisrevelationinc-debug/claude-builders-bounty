# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your repo root.
> Assumes: Next.js 15 App Router, TypeScript, Tailwind, better-sqlite3 or Turso, Drizzle ORM.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, simpler data fetching |
| Language | TypeScript 5.x | Strict mode. No `any` without comment explaining why |
| Styling | Tailwind CSS 3.4+ | Utility-first, no runtime CSS-in-JS overhead |
| Database | SQLite (better-sqlite3) or Turso | Single file = trivial local dev. Turso for edge/serverless |
| ORM | Drizzle | Type-safe SQL, no magic, compiles to plain SQL |
| Auth | Lucia + oslo (or NextAuth.js v5) | Lucia for SQLite-native sessions; NextAuth for OAuth speed |
| Validation | Zod | Same schemas for API, forms, and DB |
| Testing | Vitest + Playwright | Unit for logic, E2E for critical paths |

**Node version:** `>=20.0.0` (required for Next.js 15)

---

## Folder Structure

