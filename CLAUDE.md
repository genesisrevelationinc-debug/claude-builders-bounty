# CLAUDE.md — Next.js + SQLite SaaS Project

> This document provides context and conventions for Claude Code when working on our Next.js 15 + SQLite SaaS projects. Follow these guidelines strictly.

## Stack & Versions

- **Next.js 15** (App Router)
- **React 19** (Server Components, Actions, Compiler)
- **TypeScript 5.5+**
- **SQLite** (via `better-sqlite3` in development, `@libsql/client` for edge deployments)
- **Drizzle ORM** (migrations + type-safe queries)
- **Tailwind CSS 3** (with `@tailwindcss/postcss` for nesting)
- **Zod 3** (schema validation)

## Folder Structure

