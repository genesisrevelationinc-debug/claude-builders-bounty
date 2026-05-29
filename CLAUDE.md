# CLAUDE.md — Project Style Guide

> This document defines coding standards, conventions, and rationale for a Next.js 15 + SQLite SaaS project.  
> Claude Code should understand and follow these rules without clarification.

---

## 🧠 Stack & Conventions

### Core Stack
- **Framework**: Next.js 15 (App Router)
- **Database**: SQLite (via `better-sqlite3` or Turso/LibSQL)
- **ORM**: Drizzle ORM
- **Styling**: Tailwind CSS
- **Deployment**: Vercel

### Philosophy
- **Explicit over magic** — No hidden behavior
- **Colocation over abstraction** — Keep related code together
- **SQLite-first** — Embrace SQLite's strengths (single-file, embedded, portable)
- **Server Components by default** — Client components only when interactivity is required

---

## 📁 Project Structure

