# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code. If a rule seems arbitrary, the reason is in parentheses.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, simpler data fetching |
| Runtime | Node.js 20+ | `next` requires 18+; we target 20 for native `fetch` stability |
| Database | better-sqlite3 | Synchronous, fast, zero network overhead. Turso only if you need multi-region |
| Schema tool | `drizzle-kit` + `drizzle-orm` | Type-safe SQL, migrations as code, no query builder lock-in |
| Auth | Lucia + `oslo` | Session-based, works without OAuth providers, SQLite-native |
| Styling | Tailwind CSS + `cn()` utility | No CSS-in-JS runtime; `cn()` merges classes without conflicts |
| Forms | Server Actions + `zod` | No API routes for mutations; validation co-located with action |
| Testing | Vitest (unit) + Playwright (E2E) | Fast unit tests; real browser for critical paths |

**Lockfile rule:** Use `pnpm`. If `package-lock.json` or `yarn.lock` exists, delete it and run `pnpm install`.

---

## Folder Structure

