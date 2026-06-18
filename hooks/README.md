# Claude Code Pre-Tool-Use Hook: Block Destructive Commands

A security hook for Claude Code that intercepts and blocks dangerous bash commands before they can execute.

## What It Blocks

- `rm -rf` — Recursive force deletion
- `DROP TABLE` — SQL table deletion
- `git push --force` — Force push to remote
- `TRUNCATE` — Table truncation
- `DELETE FROM` without a `WHERE` clause — Unqualified row deletion

## Installation

