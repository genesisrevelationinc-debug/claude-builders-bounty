# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Paste this into your project root and Claude will understand your conventions without asking.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, simpler data fetching |
| Runtime | Node.js 20+ | `next` CLI requires 18+, 20+ for native `fetch` stability |
| Database | `better-sqlite3` | Synchronous, fast, zero network latency. Use Turso only if you need edge replication |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly. Avoid Prisma (wasm binary, slow init) |
| Auth | Lucia + `oslo` | Session-based, works with SQLite out of the box. Avoid NextAuth (bloated, opaque) |
| Styling | Tailwind CSS + `cn()` utility | No CSS-in-JS runtime cost. `cn()` merges `clsx` + `tailwind-merge` |
| Forms | `react-hook-form` + `zod` | Server validation via `zod` schemas shared client/server |
| Deployment | Vercel (hobby) or self-hosted Docker | `better-sqlite3` needs Node runtime; edge functions won't work with SQLite file |

**Non-negotiable:** SQLite is file-based. You cannot use Edge Runtime. All routes using DB must be `runtime: 'nodejs'`.

---

## Folder Structure

