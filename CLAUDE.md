# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your repo root.
> Assumes: Next.js 15 App Router, TypeScript, Tailwind CSS, better-sqlite3 or Turso, t3-env for env validation.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, simpler data fetching |
| Runtime | Node.js 20+ | `crypto` global, native fetch, stable ESM |
| Language | TypeScript 5.5+ | Strict mode, `noUncheckedIndexedAccess` |
| Styling | Tailwind CSS 3.4+ | Utility-first, zero runtime, design system via config |
| Database | better-sqlite3 (dev) / Turso (prod) | Single file, zero-config local dev; edge-ready with Turso |
| Migrations | `node-sqlite` custom runner | No ORM magic — explicit SQL, versioned, reversible |
| Auth | Lucia + oslo (or NextAuth.js v5) | Session in SQLite, no external auth service dependency |
| Env | t3-env + zod | Fail fast on missing/invalid env vars at build time |
| Testing | Vitest + Playwright | Unit in Node, E2E in real browser |

**Lock it down:** Use `pnpm` with `engine-strict=true` in `.npmrc`. Pin exact versions in `package.json`.

---

## Folder Structure

