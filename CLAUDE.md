# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production SaaS built with Next.js 15 App Router and SQLite.
> Paste this into your project root. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | `crypto` global, native fetch, stable ESM |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, excellent migrations |
| Auth | Lucia + `oslo` | Session-based, works with SQLite, no JWT in browser |
| Styling | Tailwind CSS 3.4 | Utility-first, no runtime CSS-in-JS overhead |
| Forms | Server Actions + `zod` | No API boilerplate, validation co-located with action |
| Testing | Vitest + Playwright | Unit + E2E, no Jest config hell |

**Pinned versions (lock these):**
