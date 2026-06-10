# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite (better-sqlite3 or Turso). Paste this into your repo root. Claude Code reads it automatically.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, nested layouts |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable ESM |
| Database | SQLite via `better-sqlite3` (local) or Turso (remote) | Zero-config local dev, edge-ready with Turso |
| ORM/Query Builder | Drizzle ORM | Type-safe SQL, lightweight, no codegen bloat |
| Auth | Lucia + `oslo` (or NextAuth.js v5 if OAuth-only) | Session-based, works with SQLite out of the box |
| Styling | Tailwind CSS + shadcn/ui | Utility-first, accessible primitives, copy-paste components |
| Validation | Zod | Schema validation shared between server and client |
| Testing | Vitest + Playwright | Unit tests in Node, E2E in real browser |

**Lock these versions in `package.json`.** Do not upgrade major versions without updating this file.

---

## Folder Structure

