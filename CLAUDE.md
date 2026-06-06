# CLAUDE.md — Engineering Guide for Next.js + SQLite SaaS

This document provides context for Claude Code to understand our stack, conventions, and development practices for our Next.js 15 + SQLite SaaS application.

## Stack & Versions

- **Framework**: Next.js 15 with App Router
- **Database**: SQLite (better-sqlite3 for local development, Turso for production)
- **ORM**: Drizzle ORM
- **Styling**: Tailwind CSS with shadcn/ui components
- **Authentication**: NextAuth.js
- **State Management**: React Context + Server Actions
- **Deployment**: Vercel
- **Package Manager**: pnpm

## Folder Structure

