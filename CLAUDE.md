# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite (better-sqlite3).
> 
> **Purpose:** Paste this into your project root. Claude Code reads it automatically and knows exactly how to work with your codebase without asking questions.

---

## Stack & Versions

| Layer | Choice | Rationale |
|-------|--------|-----------|
| Framework | Next.js 15 (App Router) | Server Components by default = simpler data flow, less client JS |
| Runtime | Node.js 20+ | Required for `crypto` global, native fetch stability |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead. Use Turso only if you need multi-region (adds async complexity) |
| ORM/Query Builder | None — raw SQL with helper functions | ORMs hide performance footguns; SQL is explicit and portable |
| Auth | `bcryptjs` + `jose` (JWT) | No third-party auth service lock-in. Sessions stored in SQLite |
| Styling | Tailwind CSS + CSS variables | Utility-first, no runtime CSS-in-JS overhead |
| Forms | Server Actions + `useActionState` | No form libraries. Native progressive enhancement |
| Validation | Zod | Schema validation shared between server and client |
| Testing | Vitest (unit), Playwright (E2E) | Fast unit tests; real browser for critical paths |

**Lock these versions in `package.json`:**
