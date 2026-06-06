# CLAUDE.md — Next.js + SQLite SaaS Project

> **Purpose**: This document provides context about our stack, conventions, and development practices for Claude Code.  
> **Goal**: Make code generation and maintenance predictable, fast, and consistent.

---

## Stack & Versions

- **Next.js** 15 App Router (React Server Components)
- **SQLite** (via `better-sqlite3` or `@libsql/client`)
- **Tailwind CSS** (with `tailwindcss-animate`)
- **TypeScript** 5+
- **Zod** for schema validation
- **React Hook Form** + **Zod** for forms
- **Drizzle ORM** (for type-safe SQL queries)

> We avoid Prisma in this stack due to bundle size and SQLite compatibility issues.

---

## Folder Structure

