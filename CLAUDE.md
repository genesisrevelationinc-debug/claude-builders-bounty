# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project context for Claude Code. Drop this into the root of any greenfield Next.js 15 + SQLite project and start coding.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default, streaming, built on React 19 |
| Runtime | Node.js 20+ | `crypto` global, native `fetch`, stable `AsyncLocalStorage` |
| Database | `better-sqlite3` | Synchronous, fast, zero network latency, perfect for single-tenant or small SaaS |
| ORM/Query Builder | Drizzle ORM | Type-safe SQL, lightweight, no hidden queries, migration-friendly |
| Auth | `oslo` + `lucia` (or `next-auth` v5 beta) | Session-based, works edge or node runtime |
| Styling | Tailwind CSS 3.4 | Utility-first, no runtime CSS-in-JS overhead |
| Forms | `react-hook-form` + `zod` | Client validation + server validation share one schema |
| Deployment | Vercel (Hobby/Pro) or self-hosted Docker | App Router optimized for Vercel; Docker for data sovereignty |

**Lock these versions in `package.json`. Do not float ranges (`^` allowed, `*` forbidden).**

---

## Folder Structure

