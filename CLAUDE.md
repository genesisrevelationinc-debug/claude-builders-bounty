# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code.  
> Last updated: 2026-03-01 · Stack: Next.js 15, React 19, TypeScript, SQLite (better-sqlite3), Tailwind CSS, shadcn/ui

---

## Stack & Versions

| Package | Version | Why |
|---------|---------|-----|
| next | ^15.0.0 | App Router, stable since 15. Server Components by default. |
| react | ^19.0.0 | Concurrent features, `use` hook for promises. |
| typescript | ^5.7 | Strict mode always. `noUncheckedIndexedAccess` on. |
| better-sqlite3 | ^11.0.0 | Synchronous SQLite. Faster than async for local DB. Turso only for multi-region deploy. |
| tailwindcss | ^4.0 | CSS-first configuration. No `tailwind.config.js` — use `@theme` in CSS. |
| shadcn/ui | latest | `npx shadcn add <component>`. Don't install manually. |

**Node:** >= 20. LTS only. No polyfills.

---

## Folder Structure

