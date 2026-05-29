# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this at the root of any greenfield Next.js 15 + SQLite project. No clarifying questions should be needed.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, simpler data fetching |
| Runtime | Node.js 20+ | `next/after`, native `fetch` with `keepalive`, stable `crypto` |
| Database | `better-sqlite3` | Synchronous, fast, zero network latency, perfect for single-tenant SaaS |
| ORM / Query Builder | Drizzle ORM | Type-safe SQL, lightweight, no codegen bloat, migrations in `.sql` |
| Auth | Lucia + `oslo` | Session-based, no JWT complexity, works with SQLite out of the box |
| Styling | Tailwind CSS 3.4 | Utility-first, no runtime CSS, purgeable |
| Forms | `react-hook-form` + `zod` | Client validation + server validation share one schema |
| Date/Time | `date-fns` | Tree-shakeable, no mutable global state like Moment |
| Testing | Vitest + Playwright | Unit tests in `__tests__`, E2E in `e2e/` |

**Non-negotiable:** We do NOT use `turbopack` in production builds. It's still experimental for complex apps. Use it in dev (`next dev --turbo`) only.

---

## Folder Structure

