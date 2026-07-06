# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> 
> **Purpose:** This file is loaded automatically by Claude Code as project context. Every rule below exists to reduce decision fatigue and prevent common foot-guns in full-stack Next.js applications.

---

## Stack & Versions

| Layer | Choice | Rationale |
|-------|--------|-----------|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, simpler data fetching |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable ESM |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead. Use Turso only if you need edge replication |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly. No Prisma (heavy binary, slow in Docker) |
| Auth | Lucia (or custom session) | Session cookies over JWT. JWT belongs in headers; we use httpOnly cookies |
| Styling | Tailwind CSS + shadcn/ui | Utility-first, no CSS-in-JS runtime cost. shadcn for rapid UI assembly |
| Validation | Zod | Same schemas for API, forms, and DB inserts |
| Testing | Vitest + Playwright | Unit tests for logic, E2E for critical flows |

**Lock these versions.** Do not upgrade major versions without updating this file.

---

## Folder Structure

