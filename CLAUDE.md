# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read before generating code. Every rule has a reason.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS |
| Runtime | Node.js 20+ | `crypto` global, native fetch, stable |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly |
| Auth | Lucia (or custom session) | No vendor lock-in, works with SQLite natively |
| Styling | Tailwind CSS + CSS variables | No runtime CSS, easy theming |
| Forms | Server Actions + `useFormState` | No API routes for mutations, progressive enhancement |
| Validation | Zod | Same schemas on server and client |
| Testing | Vitest + Playwright | Unit + E2E, fast |

**Non-negotiable:** We do not use `turso` or libsql unless explicitly migrating. `better-sqlite3` is the default because it avoids network latency, works in serverless (with proper pooling), and has zero vendor dependency.

---

## Folder Structure

