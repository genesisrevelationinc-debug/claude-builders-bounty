# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Paste this into your repo root. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | `fetch` cache controls, native `crypto`, stable `fetch` |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly |
| Auth | Lucia (or custom session) | Cookie-based sessions, works with SQLite out of the box |
| Styling | Tailwind CSS + shadcn/ui | Utility-first, accessible primitives, no runtime CSS |
| Validation | Zod | Schema validation shared between server and client |
| Testing | Vitest + Playwright | Unit tests for logic, E2E for critical flows |

**Non-negotiable:** We do not use Turso/libSQL. `better-sqlite3` is file-based, zero-config, and avoids network latency. If we need multi-region later, we migrate then—not speculatively.

---

## Folder Structure

