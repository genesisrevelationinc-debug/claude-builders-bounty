# CLAUDE.md — Next.js + SQLite SaaS Template

> This document defines the development standards and conventions for this Next.js + SQLite SaaS project. Claude Code should follow these rules strictly.

## Stack & Versions

- **Next.js 15** (App Router)
- **React 19** (Server Components, Actions, Compiler)
- **TypeScript 5.5+**
- **SQLite** (via `better-sqlite3` in development, `@libsql/client` for production/Turso)
- **Drizzle ORM** (schema-based migrations)
- **Tailwind CSS 3.4+**
- **Zod** for validation
- **next-safe-action** for server actions

## Folder Structure

