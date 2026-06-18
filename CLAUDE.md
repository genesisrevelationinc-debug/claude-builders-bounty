# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Paste this file at the root of your project. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | `fetch` cache control, native `crypto`, stable `fetch` |
| Database | `better-sqlite3` | Synchronous, fast, zero-config for single-tenant or small multi-tenant |
| ORM/Query | Raw SQL + `better-sqlite3` | SQLite is simple; ORMs add complexity without benefit here |
| Auth | `next-auth` v5 (Auth.js) or custom JWT | Auth.js has built-in OAuth providers; custom JWT for API-only |
| Styling | Tailwind CSS + CSS Modules | Tailwind for speed, CSS Modules for complex animations |
| Forms | Server Actions + `react-hook-form` | Server Actions for mutations, RHF for client validation |
| Validation | `zod` | Type-safe, works with Server Actions and RHF |
| Testing | Vitest + Playwright | Unit tests with Vitest, E2E with Playwright |
| Deployment | Vercel (with `vercel.json` limits) or Docker | SQLite requires persistent disk; Vercel needs external DB for multi-region |

**Critical constraint:** `better-sqlite3` requires a persistent filesystem. On Vercel, use a single region with `.vercel/output` excluded, or switch to Turso for serverless.

---

## Folder Structure

