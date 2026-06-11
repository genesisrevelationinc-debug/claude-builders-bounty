# Pre-Tool-Use Hook: Block Destructive Bash Commands

A Claude Code `pre-tool-use` hook that intercepts dangerous bash commands before they are executed.

## What It Blocks

- `rm -rf` — recursive force deletion
- `DROP TABLE` — SQL table deletion
- `git push --force` — force push to remote
- `TRUNCATE` — SQL table truncation
- `DELETE FROM` without a `WHERE` clause — unconditional SQL deletes

## Installation

