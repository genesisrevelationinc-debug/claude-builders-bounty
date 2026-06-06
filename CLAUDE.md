# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated conventions for a production-ready SaaS built with Next.js 15 App Router and SQLite (better-sqlite3 or Turso). Paste this into your project root. Claude Code should understand the full context without asking clarifying questions.

---

## Stack & Versions

| Layer | Choice | Rationale |
|-------|--------|-----------|
| Framework | Next.js 15 (App Router) | Server Components by default = simpler data flow, less client JS |
| Runtime | Node.js 20+ | `fetch` cache control, native `crypto`, stable ESM |
| Database | SQLite via `better-sqlite3` (local/dev) or Turso (prod) | Single file, zero-config local; edge-ready with Turso |
| ORM/Query | Raw SQL + `better-sqlite3` API | ORMs hide query plans; we want explicit, fast, debuggable SQL |
| Migrations | Custom Node.js scripts | No migration framework bloat; full control over transaction boundaries |
| Auth | `iron-session` + bcrypt | Stateless sessions, no Redis/DB dependency for auth state |
| Styling | Tailwind CSS + shadcn/ui | Utility-first, no runtime CSS; shadcn = copy-pasteable, own your components |
| Validation | Zod | Type-safe schemas shared between server and client |
| Testing | Vitest (unit) + Playwright (E2E) | Fast unit tests; real browser for critical paths |

**Lock these versions in `package.json`. Do not float majors.**

---

## Folder Structure

