# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your repo root and Claude will understand your conventions without asking.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, built on React 19 |
| Runtime | Node.js 20+ | `crypto` global, native fetch, stable ESM |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, excellent migrations |
| Auth | Lucia (or custom session) | Cookie-based sessions, works with SQLite natively |
| Styling | Tailwind CSS 3.4 | Utility-first, no runtime CSS |
| UI Components | shadcn/ui | Copy-paste, fully customizable, no npm dependency |
| Validation | Zod | Schema validation shared between server and client |
| Testing | Vitest + Playwright | Unit + E2E without conflicting configs |

**Non-negotiable:** We do NOT use `pg`, `mysql2`, or any other database driver. SQLite is the database. If you need to scale past a single node, use LiteFS or migrate later. Premature distributed data is the root of all evil.

---

## Folder Structure

