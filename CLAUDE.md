# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated conventions for a production SaaS built with Next.js 15 App Router and SQLite.
> Paste this into your project root. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Lock Version |
|-------|--------|--------------|
| Framework | Next.js 15 | `next@^15.0.0` |
| Runtime | Node.js 20+ | `.nvmrc` enforces this |
| Database | SQLite | `better-sqlite3@^11.0.0` |
| ORM | None — raw SQL | See "Why no ORM" below |
| Migrations | `node-sqlite-migrate` or hand-rolled | Versioned in `db/migrations/` |
| Auth | Lucia + `oslo` | Session cookies, not JWT |
| Styling | Tailwind CSS 3.4 | No CSS-in-JS |
| Forms | Server Actions + `zod` | No `react-hook-form` for simple cases |
| Testing | Vitest + Playwright | Unit + E2E split |

**Why this stack:** SQLite is file-based, zero-config, and fast for SaaS workloads under 100K users. No ORM means predictable queries and zero migration drift. Next.js 15 App Router with Server Actions eliminates API boilerplate.

---

## Folder Structure

