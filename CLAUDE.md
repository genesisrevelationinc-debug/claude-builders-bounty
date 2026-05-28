# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this at the root of any greenfield Next.js 15 + SQLite project. No clarifying questions should be needed.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, stable since 15.1 |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable ESM |
| Database | `better-sqlite3` | Synchronous, fast, zero network latency for single-node deploys |
| ORM / Query Builder | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly |
| Auth | Lucia + `oslo` | Session-based, works with SQLite, no OAuth lock-in |
| Styling | Tailwind CSS 3.4 | Utility-first, no runtime CSS-in-JS overhead |
| Forms | `react-hook-form` + `zod` | Client validation + server validation share one schema |
| Deployment | Docker + Fly.io / Railway | SQLite is a file; persist with volumes, not ephemeral storage |

**Non-negotiable:** We do NOT use Turso/libSQL. This template targets single-node or replicated-file deployments. If you need distributed SQLite, fork this template.

---

## Folder Structure

