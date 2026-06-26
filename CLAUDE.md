# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code. If a rule seems
> arbitrary, the "Why" explains the trade-off. When in doubt, follow the
> pattern, not the exception.

---

## Stack & Versions

| Layer | Choice | Version Lock |
|-------|--------|--------------|
| Framework | Next.js | 15.x (App Router only) |
| Runtime | Node.js | >= 20 LTS |
| Database | better-sqlite3 | latest (local) / libsql (Turso remote) |
| ORM/Query | Drizzle ORM | latest |
| Auth | Lucia + Oslo | latest (or NextAuth.js v5 if OAuth-only) |
| Styling | Tailwind CSS | 3.x |
| UI Components | shadcn/ui | latest |
| Validation | Zod | latest |
| Testing | Vitest + Playwright | latest |

**Why this stack:** SQLite eliminates infrastructure overhead for 0-10k user
SaaS. better-sqlite3 is synchronous (faster for single-node), Drizzle gives
type-safe SQL, and the rest are community defaults with Claude Code training
data.

---

## Folder Structure

