# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code.  
> Paste this at the root of any greenfield Next.js 15 + SQLite project.  
> Last updated: 2025-01

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, stable |
| Runtime | Node.js 20+ | `crypto` global, native fetch, stable ESM |
| Database | `better-sqlite3` | Synchronous, fast, zero network latency for single-node deploys |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, excellent migrations |
| Auth | Lucia + `oslo` | Session-based, works with SQLite, no OAuth lock-in |
| Styling | Tailwind CSS + `cn()` | Utility-first, no runtime CSS-in-JS overhead |
| Forms | `react-hook-form` + `zod` | Server validation + client validation share schema |
| Testing | Vitest + Playwright | Unit + E2E without Jest's cache bugs |

**Non-negotiable:** We do NOT use Prisma with SQLite. Prisma's query engine adds a Rust binary, connection pooling complexity, and slower cold starts for zero benefit on a local-file database.

---

## Folder Structure

