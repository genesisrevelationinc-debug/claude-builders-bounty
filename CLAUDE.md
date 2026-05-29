# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code. If Claude suggests something that contradicts this file, Claude is wrong.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = simpler data fetching, less client JS |
| Runtime | Node.js 20+ | `crypto.randomUUID` native, stable fetch, no polyfills |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead. Turso only if you need edge replicas |
| ORM/Query | Drizzle ORM | Type-safe SQL, zero runtime bloat, migrations are just SQL files |
| Auth | Lucia + `oslo` | Session cookies, no JWT in localStorage. Roll your own or use Clerk |
| Styling | Tailwind CSS + `cn()` | Utility-first, no CSS-in-JS runtime cost |
| Forms | `react-hook-form` + Zod | Server validation with `useFormState` for progressive enhancement |
| Testing | Vitest + Playwright | Unit tests run in <1s, E2E covers critical paths only |

**Lockfile rule:** `package-lock.json` or `pnpm-lock.yaml` must be committed. No `yarn`.

---

## Folder Structure

