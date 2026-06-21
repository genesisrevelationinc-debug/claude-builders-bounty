# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this at the root of any greenfield Next.js 15 + SQLite project. No clarifying questions should be needed.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, stable since 15.1 |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `sqlite` |
| Database | `better-sqlite3` | Synchronous, fast, no connection pool complexity for single-node deploys |
| ORM/Query | Raw SQL + `zod` | ORMs hide performance footguns; Zod validates at boundaries |
| Auth | `bcryptjs` + `jose` (JWT) | No third-party auth service dependency; works offline |
| Styling | Tailwind CSS 3.4+ | Utility-first, zero runtime, design system via config |
| Forms | Server Actions + `react-hook-form` | Server Actions for mutations; RHF for client validation UX |
| Testing | Vitest + Playwright | Unit: Vitest (fast, ESM). E2E: Playwright (real browser) |

**Non-negotiable:** We do not use `turso` or any edge-hosted SQLite. This template targets single-node deploys (VPS, Railway, Fly.io single region). If you need multi-region, switch to Postgres — do not force SQLite into that shape.

---

## Folder Structure

