# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite. Read this before writing code. If Claude suggests something that contradicts this file, push back.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, built on React 19 |
| Runtime | Node.js 20+ | `next dev` requires 18+, we target LTS |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead. Use Turso only if you need multi-region |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, excellent migrations |
| Auth | Lucia + `oslo` | Session-based, works with SQLite out of the box |
| Styling | Tailwind CSS + `shadcn/ui` | Utility-first, accessible primitives, no CSS-in-JS runtime |
| Validation | Zod | Same schemas for client, server, and DB |
| Testing | Vitest + Playwright | Unit tests in-memory SQLite, E2E against built app |

**Lock these versions.** Do not upgrade major versions without updating this file.

---

## Folder Structure

