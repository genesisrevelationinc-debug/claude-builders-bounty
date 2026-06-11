# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Every rule below exists because we shipped with the opposite and regretted it.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, simpler data flow |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `structuredClone` |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead. Use Turso only if you need multi-region |
| Query Builder | `drizzle-orm` + `drizzle-kit` | Type-safe SQL, zero runtime bloat, migrations are just SQL files |
| Auth | `oslo` + `lucia` (or `next-auth` v5 if you need OAuth fast) | Session cookies, no JWT in localStorage |
| Styling | Tailwind CSS + `shadcn/ui` | Utility-first, copy-paste components, no version drift |
| Validation | `zod` | Single source of truth for API + form validation |
| Testing | Vitest (unit) + Playwright (E2E) | Fast unit tests, real browser for critical paths |

**Lockfile rule:** `package-lock.json` or `pnpm-lock.yaml` must be committed. CI fails if lockfile drifts.

---

## Folder Structure

