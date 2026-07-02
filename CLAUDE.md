# CLAUDE.md equivalents

## Stack & Versions

- **Next.js**: 15.x with App Router (no Pages Router)
- **React**: 19.x
- **TypeScript**: 5.7+
- **SQLite**: `better-sqlite3` for local/dev, `libsql` (Turso) for production
- **ORM**: None. Use raw SQL via `better-sqlite3` or `@libsql/client`. ORMs hide query plans and make migrations opaque.
- **Styling**: Tailwind CSS 4.x + shadcn/ui for components
- **Auth**: `next-auth` (Auth.js) v5 with credentials provider backed by SQLite, or `lucia` + `oslo` if you need session control
- **Validation**: `zod` for runtime validation, `drizzle-zod` only if you must

### Why this stack

SQLite is sufficient for 95% of SaaS workloads until you hit >10k concurrent writes. The single-file model simplifies backups and testing. Next.js 15 App Router with Server Components eliminates an entire class of data-fetching bugs.

---

## Folder Structure

