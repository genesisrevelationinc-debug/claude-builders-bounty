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
| Auth | Lucia + `oslo` | Session-based, works with SQLite out of the box, no external auth service |
| Styling | Tailwind CSS 3.4 + `cn()` utility | Utility-first, no runtime CSS, `tailwind-merge` + `clsx` for variants |
| Forms | `react-hook-form` + `zod` | Client validation mirrors server schema, single source of truth |
| Date/Time | `date-fns` | Tree-shakeable, no mutable moment.js footguns |
| Testing | Vitest + `msw` + Playwright | Unit, API mock, and E2E without Jest config hell |

**Non-negotiable:** We do NOT use Turso/libSQL. `better-sqlite3` is local-first; if we need multi-region later, we migrate to Postgres. Don't add distributed-system complexity for a single SQLite file.

---

## Folder Structure

