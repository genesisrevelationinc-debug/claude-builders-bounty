# CLAUDE.md — AI Assistant Onboarding Guide

> **Purpose**: This document ensures Claude (and other AI assistants) produce
> high-quality, consistent code when contributing to this codebase.
>
> **Last updated**: 2024-03-15
> **Stack**: Next.js 14 (App Router), TypeScript, SQLite (better-sqlite3), Tailwind CSS

---

## 1. Folder Structure & Naming Conventions

### Absolute Rules
- **Use kebab-case for ALL file and folder names**: `user-profile.tsx`, `api/webhooks/route.ts`
- **PascalCase ONLY for React component exports**: `export function UserProfile() {}`
- **camelCase for utilities, hooks, and non-component files**: `useAuth.ts`, `dbHelpers.ts`
- **NO index files as barrel exports** — import directly from source

