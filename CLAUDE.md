# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this at the root of any greenfield Next.js + SQLite SaaS project. No clarifying questions should be needed.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, stable since Oct 2024 |
| Runtime | Node.js 20+ | `fetch` cache control, native `crypto`, long-term support |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys. Use Turso only if you need multi-region edge |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly. No Prisma (heavy, slow startup) |
| Auth | Lucia (or custom session) | No NextAuth bloat. Sessions stored in SQLite, cookies httpOnly + secure |
| Styling | Tailwind CSS + shadcn/ui | Utility-first, copy-paste components, no runtime CSS-in-JS |
| Validation | Zod | Same schemas for API, forms, and DB |
| Testing | Vitest + Playwright | Unit tests in-memory SQLite, E2E on real build |
| Deploy | Docker + Fly.io / Railway | SQLite is a file; persistent volume required. Vercel = wrong tool |

**Non-negotiable:** Node 20+, Next.js 15, App Router, Server Components default.

---

## Folder Structure

