# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code.  
> Last updated: 2025-01

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, simpler data fetching |
| Runtime | Node.js 20+ | `crypto.randomUUID` native, stable fetch, long-term support |
| Database | `better-sqlite3` | Synchronous, fast, zero network latency. Use Turso only if you need multi-region |
| ORM/Query | Drizzle ORM | Type-safe SQL, lightweight, migration-friendly. No Prisma (engine binary bloat) |
| Auth | Lucia + `oslo` | Session-based, works with SQLite out of the box. No JWT in cookies |
| Styling | Tailwind CSS + `cn()` utility | No CSS-in-JS runtime cost. `cn()` merges without surprises |
| Forms | Server Actions + `zod` | No API routes for mutations. Validate on the server, revalidate paths |
| Deployment | Docker / VPS | SQLite is a file. Don't use serverless platforms that wipe ephemeral storage |

**Lock these versions.** Do not upgrade major versions without updating this file.

---

## Folder Structure

