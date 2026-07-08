# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code. Claude uses this as ground truth.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, stable since 15 |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable ESM |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Raw SQL + `zod` | No ORM magic. Explicit schemas prevent drift. |
| Auth | `lucia` + `oslo` | Session-based, works with SQLite, no JWT in cookies |
| Styling | Tailwind CSS 3.4 | Utility-first, no runtime CSS-in-JS overhead |
| Forms | Server Actions + `zod` | No API routes for mutations. Type-safe from form to DB. |
| Testing | Vitest + Playwright | Unit + E2E. No Jest (slow, ESM pain). |

**Pinned in `package.json`:** Use exact versions, not `^`. Renovate handles bumps.

---

## Folder Structure

