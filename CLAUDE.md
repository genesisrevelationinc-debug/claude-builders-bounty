# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, stable since 15.1 |
| Runtime | Node.js 20+ | `crypto` global, native fetch, stable ESM |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Raw SQL + `better-sqlite3` | ORMs hide query plans; we want explicit control for SQLite's limited optimizer |
| Migrations | `node-sqlite3-migrations` or custom script | Versioned, reversible, committed to repo |
| Styling | Tailwind CSS 3.4+ | Utility-first, no runtime CSS-in-JS overhead |
| Forms | Server Actions + `react-hook-form` | Server Actions for mutations, RHF for client validation |
| Auth | `bcryptjs` + `jose` (JWT) | No external auth provider dependency; JWT in httpOnly cookie |
| Testing | Vitest + Playwright | Unit tests with `better-sqlite3` in-memory DB; E2E with Playwright |

**Non-negotiable:** All code targets ESM. No `require()`.

---

## Folder Structure

