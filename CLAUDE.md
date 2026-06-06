# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code. If Claude suggests something that contradicts this file, the file wins.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, simpler data flow |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `AsyncLocalStorage` |
| Database | better-sqlite3 | Synchronous SQLite = simpler transactions, no connection pool hell |
| ORM/Query | Drizzle ORM | Type-safe SQL, zero runtime bloat, migration files are plain SQL |
| Auth | Lucia + oslo | Session cookies, no JWT in localStorage. Works with SQLite out of the box |
| Styling | Tailwind CSS + shadcn/ui | Copy-paste components, no phantom dependency on a component library |
| Validation | Zod | Same schemas for API, forms, and DB |
| Testing | Vitest + Playwright | Unit tests for logic, E2E for critical flows |

**Pinned versions (do not upgrade without discussion):**
- `next`: `15.0.0` — App Router stable, `dynamicIO` experimental
- `better-sqlite3`: `^11.0.0` — native module, pin to avoid rebuild issues
- `drizzle-orm`: `^0.36.0` — watch for breaking changes in `0.37`

---

## Folder Structure

