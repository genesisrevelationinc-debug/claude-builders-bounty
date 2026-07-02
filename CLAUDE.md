# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Paste this file at your project root. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `sqlite` module |
| Database | `better-sqlite3` | Synchronous, fast, zero-config for single-tenant deploys |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, excellent migrations |
| Auth | Lucia + `oslo` | Session-based, works with SQLite, no external deps |
| Styling | Tailwind CSS 3.4 | Utility-first, no runtime CSS-in-JS overhead |
| Forms | `react-hook-form` + `zod` | Type-safe validation, works in Server Actions |
| Deployment | Docker + Fly.io / Railway | SQLite requires persistent volume; avoid serverless |

**Non-negotiable:** We do NOT use `turso` or any libsql fork. `better-sqlite3` requires a local file. If you need edge replication, use Postgres. SQLite on a network filesystem (EFS, NFS) corrupts. Deploy to a single VM with a persistent volume.

---

## Folder Structure

