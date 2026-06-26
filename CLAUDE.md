# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your repo root and Claude will understand your conventions without asking questions.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, built on React 19 |
| Runtime | Node.js 20+ | `fetch` cache changes, native `crypto`, LTS |
| Database | better-sqlite3 | Synchronous, fast, zero network overhead for single-tenant or small SaaS |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly |
| Auth | Lucia (or custom session) | No vendor lock-in, works with SQLite natively |
| Styling | Tailwind CSS + shadcn/ui | Copy-paste components, no runtime CSS-in-JS |
| Validation | Zod | Same schemas for API, forms, and DB |
| Testing | Vitest + Playwright | Unit + E2E without Jest config hell |

**Non-negotiable:** We do not use Prisma. The query engine binary adds Docker complexity and cold-start latency that defeats the purpose of SQLite.

---

## Folder Structure

