# CLAUDE.md — Next.js 15 + SQLite SaaS Template

## Stack & Versions

- **Runtime**: Node.js 22 LTS
- **Framework**: Next.js 15 (App Router)
- **Database**: SQLite via `better-sqlite3` (local dev) or Turso/libsql (production)
- **ORM**: Drizzle ORM (lightweight, SQL-first, no codegen bloat)
- **Auth**: NextAuth.js v5 (Auth.js) with credential + OAuth providers
- **Styling**: Tailwind CSS v4 + shadcn/ui (Radix primitives)
- **Validation**: Zod (shared types between client/server)
- **Payments**: Stripe (checkout sessions + webhooks)
- **Email**: Resend (transactional emails)
- **Hosting**: Vercel (frontend) + Turso (DB edge replicas)

## Folder Structure

