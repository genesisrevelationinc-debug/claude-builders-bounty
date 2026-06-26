# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Paste this file at repo root. Claude Code reads it automatically for context.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, built on React 19 |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `sqlite` module |
| Database | `better-sqlite3` | Synchronous, fast, zero async/await complexity for SQLite |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, excellent migrations |
| Auth | Lucia (or custom session) | Cookie-based sessions stored in SQLite, no external deps |
| Styling | Tailwind CSS 3.4+ | Utility-first, no runtime CSS-in-JS overhead |
| Forms | Server Actions + `react-hook-form` | Progressive enhancement, no API route boilerplate |
| Validation | Zod | Same schemas on server and client, TypeScript inference |
| Testing | Vitest + Playwright | Unit tests in Node, E2E in real browser |

**Hard rule:** No `pg`, `mysql2`, or other DB drivers. SQLite only. Single-file portability is a feature.

---

## Folder Structure

