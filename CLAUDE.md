# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code.  
> Goal: zero clarifying questions, consistent decisions, fast shipping.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS |
| Runtime | Node.js 20+ | `crypto` global, native fetch, stable |
| Database | `better-sqlite3` | Synchronous, fast, no connection pool complexity |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly |
| Auth | Lucia + `oslo` | Session-based, works with SQLite, no OAuth lock-in |
| Styling | Tailwind CSS + `cn()` | Utility-first, no runtime CSS |
| Forms | `react-hook-form` + Zod | Server validation + client validation same schema |
| Testing | Vitest + Playwright | Unit + E2E, both fast |

**Hard rule:** No version pinning with `^`. Use exact versions in `package.json` to prevent "works on my machine". Renovate handles bumps.

---

## Folder Structure

