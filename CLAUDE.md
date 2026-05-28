# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated conventions for a production SaaS built with Next.js 15 App Router, SQLite (better-sqlite3 or Turso), and TypeScript.
> 
> **Rule of thumb:** If a convention isn't here, it doesn't exist. If it exists, it has a reason.

---

## Stack & Versions

| Layer | Choice | Version Constraint | Why |
|-------|--------|-------------------|-----|
| Framework | Next.js | `15.x` (App Router only) | Server Components by default, streaming, stable |
| Runtime | Node.js | `>=20` | `crypto` global, native `fetch`, performance |
| Language | TypeScript | `5.x`, `strict: true` | Catch errors at compile time, not 2am |
| Database | SQLite via `better-sqlite3` or `@libsql/client` | `better-sqlite3@^11` / `@libsql/client@^0.x` | Synchronous, fast, zero network latency in dev; Turso for prod edge |
| ORM/Query Builder | Drizzle ORM | `drizzle-orm@^0.x` | Type-safe SQL, migrations as code, no hidden queries |
| Styling | Tailwind CSS | `^3.4` | Utility-first, no runtime CSS, design system via tokens |
| UI Components | shadcn/ui | Install via CLI | Copy-paste ownership, no version lock-in |
| Validation | Zod | `^3.x` | Single source of truth for runtime + static types |
| Auth | NextAuth.js v5 (Auth.js) or Lucia | `next-auth@^5` / `lucia@^3` | Don't roll your own crypto |

**Hard no:** Prisma with SQLite (connection pooling issues, unnecessary complexity). Use Drizzle.

---

## Project Structure

