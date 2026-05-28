# CLAUDE.md — Next.js + SQLite SaaS Template

> **Opinionated development guide for Claude Code contributors**

This document defines our conventions, patterns, and anti-patterns for a production-ready SaaS built with:

- **Next.js 15** (App Router)
- **SQLite** (via `better-sqlite3` or Turso)
- **Tailwind CSS**
- **TypeScript**

## Stack & Versions

- Node.js 20.x
- Next.js 15.x (App Router)
- React 19.x (Server Components, Server Actions)
- TypeScript 5.x
- Tailwind CSS 3.x
- SQLite (better-sqlite3 or Turso)
- Drizzle ORM (for migrations and typesafe queries)

## Folder Structure

