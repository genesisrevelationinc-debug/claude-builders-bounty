# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, stable since 15.1 |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable ESM |
| Database | `better-sqlite3` | Synchronous, fast, no connection pool complexity for single-node deploys |
| ORM | None — raw SQL with helpers | SQLite is simple; ORMs add indirection and migration pain |
| Styling | Tailwind CSS 3.4+ | Utility-first, no runtime CSS, works with RSC |
| Forms | Server Actions + `useFormStatus` | No API routes needed for mutations |
| Auth | `bcryptjs` + `jose` (JWT) | No external auth service dependency; sessions in SQLite |
| Validation | `zod` | Type-safe schemas shared between client and server |

**Non-negotiable:** We do not use Turso, Prisma, or tRPC. These add network latency, build-time codegen, or RPC indirection that SQLite-on-same-node does not need.

---

## Folder Structure

