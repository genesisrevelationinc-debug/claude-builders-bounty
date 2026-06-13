# Pre-Tool-Use Hook: Block Destructive Bash Commands

A Claude Code `pre-tool-use` hook that intercepts dangerous bash commands before they are executed.

## What It Blocks

- `rm -rf` — recursive force delete
- `DROP TABLE` — SQL table deletion
- `TRUNCATE` — SQL table truncation
- `DELETE FROM` without a `WHERE` clause — unqualified SQL deletion
- `git push --force` / `git push -f` — force push

## Installation

