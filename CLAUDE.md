# CLAUDE.md — Next.js 15 + SQLite SaaS

> Opinionated project conventions. Read this before writing code. If a rule seems arbitrary, the reason is in parentheses.

---

## Stack & Versions

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 15 (App Router) | Server Components by default = less client JS, simpler data flow |
| Runtime | Node.js 20+ | `next/after`, stable `fetch` |
| Database | `better-sqlite3` | Synchronous, fast, zero network overhead for single-node deploys |
| ORM/Query | Raw SQL + `zod` | ORMs hide performance cliffs; Zod gives type safety without codegen bloat |
| Auth | `lucia` permissive + `oslo` | Session-based, works with SQLite, no OAuth lock-in |
| Styling | Tailwind CSS + `shadcn/ui` | Copy-paste components, no phantom dependency updates |
| Validation | `zod` | Single source of truth for API + DB + forms |
| Testing | Vitest + Playwright | Unit tests run in <1s; E2E catches routing regressions |

**Pinned in `package.json`:** All major versions use exact pins (`"next": "15.0.3"`, not `^15.0.3`). Renovate opens PRs; we merge after reading changelogs.

---

## Folder Structure

