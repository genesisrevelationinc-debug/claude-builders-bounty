# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your repo root and Claude will understand your conventions without asking.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, simpler data fetching |
| Runtime | Node.js 20+ | `next` requires 18.17+, 20+ for stable fetch/streams |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead. Use Turso only if you need edge replicas |
| ORM/Query | Raw SQL + `better-sqlite3` | ORMs hide query plans; we write SQL to own performance from day one |
| Auth | `lucia` + `oslo` | Session-based, no JWT bloat, works with SQLite out of the box |
| Styling | Tailwind CSS 3.4 | Utility-first, no runtime CSS-in-JS overhead |
| Forms | Server Actions + `zod` | No API routes to maintain; validation co-located with action |
| Testing | Vitest + Playwright | Unit tests run in <1s; E2E covers critical paths |

**Lockfile rule:** `package-lock.json` only. Delete `yarn.lock`/`pnpm-lock.yaml` on sight — mixed lockfiles break CI reproducibility.

---

## Folder Structure

