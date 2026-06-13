# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your repo root and Claude will understand your conventions without asking.

---

## Stack & Versions

| Layer | Choice | Rationale |
|-------|--------|-----------|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, built on React 19 |
| Runtime | Node.js 20+ | `crypto.randomUUID()` native, stable fetch, performance |
| Database | `better-sqlite3` | Synchronous, fast, zero network latency, perfect for single-tenant SaaS |
| ORM/Query | Drizzle ORM | Type-safe SQL, zero runtime bloat, migration-first |
| Auth | Lucia (or custom JWT) | Session cookies, no OAuth complexity for MVP |
| Styling | Tailwind CSS 3.4 + shadcn/ui | Utility-first, copy-paste components, no version drift |
| Validation | Zod | Same schemas for API, forms, and DB |
| Testing | Vitest + Playwright | Unit tests in-memory SQLite, E2E on real build |

**Non-negotiable:** We use the App Router. Pages Router code is rejected in PR review.

---

## Folder Structure

