# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated conventions for this repo.  
> If Claude Code (or you) is generating code, it follows this file. No generic advice — every rule has a reason.

---

## Stack & Versions

| Layer | Choice | Pin / Note |
|-------|--------|------------|
| Framework | Next.js 15 (App Router) | Use `async` Server Components by default |
| Runtime | Node.js 20+ | |
| Database | SQLite via `better-sqlite3` | Local file for dev, `libsql`/`turso` client for prod |
| ORM / Query | Drizzle ORM | See **Migrations** below |
| Auth | NextAuth.js v5 (Auth.js) | Credentials provider + JWT session |
| Styling | Tailwind CSS + shadcn/ui | Base color: `neutral` |
| Validation | Zod | Reuse schemas in API + forms |
| Testing | Vitest + Playwright | Unit: `*.test.ts`; E2E: `*.spec.ts` |

---

## Folder Structure

