# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code. Every rule has a reason.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = simpler data flow |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `sqlite` |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Raw SQL + `better-sqlite3` | ORMs hide performance cliffs; we own our schema |
| Migrations | Custom Node.js scripts | No hidden migration framework behavior |
| Auth | `bcryptjs` + `jose` (JWT) | No external auth service dependency at this scale |
| Styling | Tailwind CSS 3.4+ | Utility-first, zero runtime, design system via config |
| Forms | Server Actions + `useFormState` | No client-side form libraries; server is source of truth |
| Validation | `zod` | Single source of truth for API and form validation |

**Lockfile rule:** `package-lock.json` is committed. No `yarn`, no `pnpm` for this repo.

---

## Folder Structure

