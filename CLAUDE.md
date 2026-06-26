# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, stable since 15.1 |
| Runtime | Node.js 20+ | `crypto.randomUUID()` native, stable fetch, no polyfills |
| Database | `better-sqlite3` | Synchronous, fast, zero network latency for single-node deploys |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly |
| Auth | Lucia (or custom session) | No vendor lock-in, works with SQLite natively |
| Styling | Tailwind CSS + shadcn/ui | Copy-paste components, no runtime CSS overhead |
| Validation | Zod | Same schemas for API, forms, and DB |
| Testing | Vitest + Playwright | Unit + E2E without Jest's baggage |

**Non-negotiable:** We do not use `turso` or `libsql` unless deploying to the edge. `better-sqlite3` is simpler, faster, and has fewer failure modes for traditional server deploys (VPS, Railway, Fly.io).

---

## Folder Structure

