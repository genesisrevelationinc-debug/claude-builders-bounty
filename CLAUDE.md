# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your repo root.
> Assumes: Next.js 15 (App Router), TypeScript, Tailwind CSS, better-sqlite3, Zod.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = simpler data flow |
| Runtime | Node.js 20+ | `better-sqlite3` requires native bindings, no Edge |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-tenant |
| ORM/Query | Raw SQL + Zod | No ORM magic. Schema is the source of truth. |
| Auth | `bcryptjs` + `jose` (JWT) | No external auth service dependency |
| Styling | Tailwind CSS + `shadcn/ui` | Copy-paste components, full control |
| Validation | Zod | Same schemas on server and client |
| Testing | Vitest + Playwright | Unit for logic, E2E for critical paths |

**Non-negotiable:** This stack runs on Node.js runtime only. Do NOT use Edge Runtime.
`better-sqlite3` is native and must run in Node.js. Edge = broken.

---

## Folder Structure

