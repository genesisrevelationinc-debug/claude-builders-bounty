# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your repo root and Claude will understand your conventions without asking.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, built on React 19 |
| Runtime | Node.js 20+ | `next dev` uses Node; edge runtime avoided for DB access |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys. Use `libsql` / `@libsql/client` only if targeting Turso |
| ORM/Query | Drizzle ORM | Type-safe SQL, migrations in TS, no codegen step. Avoid Prisma (heavy, slow on SQLite) |
| Auth | Lucia + `oslo` | Lightweight, session-based, works with SQLite out of the box. Avoid NextAuth (bloated, opaque) |
| Styling | Tailwind CSS 3.4 + `tailwind-merge` + `clsx` | Utility-first, no runtime CSS-in-JS overhead |
| Forms | `react-hook-form` + `zod` | Server-validated, type-safe from edge to DB |
| Testing | Vitest + `msw` + Playwright | Unit, API mock, and E2E layers |

**Non-negotiable:** All code is TypeScript. `strict: true`. No `any` without a `// claude-allow-any: <reason>` comment.

---

## Folder Structure

