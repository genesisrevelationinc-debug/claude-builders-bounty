# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your repo root.
> Assumes: Next.js 15 App Router, better-sqlite3, TypeScript, Tailwind CSS, shadcn/ui.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = simpler data flow, less client JS |
| Runtime | Node.js 20+ | `better-sqlite3` requires native bindings; Edge runtime breaks this |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead. Turso only if you need multi-region |
| ORM/Query | Raw SQL + `better-sqlite3` | ORMs hide performance footguns in SQLite. Migrations in plain SQL are reviewable |
| Auth | `bcryptjs` + `jose` (JWT) | No external auth service dependency. SQLite stores sessions if needed |
| Styling | Tailwind CSS 3.4+ | Utility-first prevents CSS class proliferation |
| Components | shadcn/ui | Copy-paste components = full control, no version lock-in |
| Validation | `zod` | Share schemas between server and client. Always validate at boundary |
| Testing | Vitest + Playwright | Unit for logic, E2E for critical paths |

**Hard rule:** Do not use Prisma, Drizzle, or any query builder. They generate SQL you cannot easily review and often produce suboptimal SQLite queries (N+1, unnecessary CTEs).

---

## Folder Structure

