# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code. Every rule has a reason.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, built on React 19 |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `TextEncoder` |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, excellent migrations |
| Auth | Lucia + `better-sqlite3` adapter | Session-based, no JWT bloat, works offline |
| Styling | Tailwind CSS 3.4 | Utility-first, no runtime CSS-in-JS overhead |
| Forms | `react-hook-form` + Zod | Client validation mirrors server schema |
| Deployment | Self-hosted or Railway/Render | SQLite is file-based; avoid serverless (cold starts = db path hell) |

**Non-negotiable:** We do NOT use Turso. Turso is async, adds network latency, and complicates local dev. `better-sqlite3` is synchronous and sufficient for 99% of SaaS workloads. If you outgrow it, migrate to Postgres deliberately, not reactively.

---

## Folder Structure

