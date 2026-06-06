# Pre-Tool-Use Hook: Block Destructive Bash Commands

A Claude Code `pre-tool-use` hook that intercepts and blocks dangerous bash commands before they can execute.

## What It Blocks

- `rm -rf` — recursive force delete
- `DROP TABLE` — SQL table deletion
- `git push --force` / `git push -f` — force push overwriting history
- `TRUNCATE` — removes all data from a table
- `DELETE FROM` without a `WHERE` clause — removes all rows

## Installation

