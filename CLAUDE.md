# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code. If a pattern isn't here, it doesn't belong.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, simpler data flow |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `AsyncLocalStorage` |
| Database | `better-sqlite3` | Synchronous, fast, zero network latency, works in Server Components |
| ORM/Query | Raw SQL + `zod` | ORMs hide performance cliffs; Zod gives type safety without abstraction bloat |
| Auth | `lucia` + `oslo` | Session-based, works with SQLite out of the box, no external auth service |
| Styling | Tailwind CSS + `shadcn/ui` | Utility-first, no runtime CSS, copy-paste components = full control |
| Validation | `zod` | Single source of truth for API, forms, and DB schemas |
| Testing | `vitest` + `@testing-library/react` | Fast, native ESM, no Jest config hell |

**Lockfile rule:** `package-lock.json` is source of truth. Never commit `yarn.lock` or `pnpm-lock.yaml`.

---

## Folder Structure

