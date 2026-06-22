# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code.  
> Paste this at the root of any greenfield Next.js + SQLite project.  
> Last updated: 2025-01

---

## Stack & Versions

| Layer | Choice | Rationale |
|-------|--------|-----------|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, built on React 19 |

**Why not Turso?** Turso is excellent for edge, but this template optimizes for single-region, single-node simplicity. If you need edge later, migrate to Turso's libSQL client—Drizzle supports both.

---

## Folder Structure

