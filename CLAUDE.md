# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this at the root of any greenfield Next.js 15 + SQLite project. No clarifying questions should be needed.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, built on React 19 |
| Runtime | Node.js 20+ | `next dev` requires 18+, 20+ for stable fetch + native APIs |
| Database | `better-sqlite3` | Synchronous, fast, zero network latency for single-tenant/SaaS monolith |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, excellent migration tooling |
| Auth | Lucia (or custom session) | No vendor lock-in, works with SQLite natively |
| Styling | Tailwind CSS 3.4+ | Utility-first, no runtime CSS-in-JS overhead |
| Forms | Server Actions + `useFormState` | No API routes needed, progressive enhancement built-in |
| Validation | Zod | Same schemas on server and client, tiny bundle |
| Testing | Vitest + Playwright | Unit + E2E, both fast |

**Non-negotiable:** We do not use `turso` unless the project explicitly needs edge replication. `better-sqlite3` is the default because it avoids async/await contagion in Server Components and keeps the mental model simple.

---

## Folder Structure

