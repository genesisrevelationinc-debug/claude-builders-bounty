# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite.
> Paste this file at the root of your project. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Rationale |
|-------|--------|-----------|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, built on React 19 |
| Runtime | Node.js 20+ | `next dev` requires 18+; we target 20 for native `fetch` stability |

**Lockfile rule:** Use `pnpm`. If `package-lock.json` or `yarn.lock` exists, delete it and run `pnpm install`. Rationale: deterministic resolution, disk-efficient, fast.

---

## Folder Structure

