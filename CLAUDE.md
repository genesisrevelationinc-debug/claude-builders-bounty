# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into the root of any greenfield Next.js 15 + SQLite project. No clarifying questions should be needed.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, stable |
| Runtime | Node.js 20+ | `better-sqlite3` requires native bindings |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-tenant SQLite |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly |
| Auth | Lucia + `oslo` | Session-based, works without external providers |
| Styling | Tailwind CSS 3.4 | Utility-first, no runtime CSS-in-JS overhead |
| Forms | Server Actions + `zod` | No API routes needed, validation co-located |
| Testing | Vitest + Playwright | Unit + E2E without Jest's module pain |

**Hard constraints:**
- Node 20+ required (`better-sqlite3` native bindings)
- No Edge Runtime (`better-sqlite3` is Node-only)
- No Docker for local dev (SQLite is a file)

---

## Folder Structure

