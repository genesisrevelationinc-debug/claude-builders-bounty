# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite (better-sqlite3). Read this before writing code. If a rule seems arbitrary, the "Why" explains it.

---

## Stack & Versions

| Layer | Choice | Version Constraint |
|-------|--------|------------------|
| Framework | Next.js | `15.x` (App Router only — no Pages Router) |
| Runtime | Node.js | `>=20` (native `fetch`, `crypto`, `structuredClone`) |
| Database | better-sqlite3 | `^11.x` (synchronous, fast, no connection pool hell) |
| ORM/Query Builder | None. Raw SQL with helpers | See "SQL / migration conventions" |
| Styling | Tailwind CSS | `^3.4` |
| UI Primitives | shadcn/ui | Install via CLI, not npm directly |
| Auth | Lucia (or custom session cookies) | Avoid OAuth-only; always have password fallback |
| Payments | Stripe | Webhook handlers in `app/api/webhooks/stripe/` |
| Deployment | Vercel (frontend) + Fly.io/Railway (SQLite) or Turso | SQLite is file-based; read "Deployment" |

**Why this stack:** Next.js 15 App Router enables server components by default — use them. SQLite is sufficient for 95% of SaaS workloads until you hit >10k writes/second. better-sqlite3 is synchronous and simpler than async pools for SQLite's single-writer model. No ORM — SQL is the ORM; abstractions leak and slow you down on complex queries.

---

## Folder Structure

