# Pre-Tool-Use Hook: Block Destructive Bash Commands

A Claude Code `pre-tool-use` hook that intercepts and blocks dangerous bash commands before they can execute.

## What It Blocks

- `rm -rf` — recursive force delete
- `DROP TABLE` — deletes database tables
- `git push --force` / `git push -f` — overwrites remote history
- `TRUNCATE` — removes all table data
- `DELETE FROM` without a `WHERE` clause — deletes all rows

## Installation

