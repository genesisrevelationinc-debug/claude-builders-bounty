# Claude Code Pre-Tool-Use Hook: Block Destructive Commands

A security hook for Claude Code that intercepts and blocks dangerous bash commands before they execute.

## What It Blocks

- `rm -rf` / `rm -f` — destructive file removal
- `DROP TABLE` — database table deletion
- `git push --force` / `git push -f` — force pushes
- `TRUNCATE` — table truncation
- `DELETE FROM` without a `WHERE` clause — accidental data deletion

## Installation

