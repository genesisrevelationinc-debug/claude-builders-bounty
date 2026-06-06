# Pre-Tool-Use Hook: Block Destructive Bash Commands

A Claude Code `pre-tool-use` hook that intercepts and blocks dangerous bash commands before they can be executed.

## What It Blocks

- `rm -rf` — recursive force deletion
- `DROP TABLE` — SQL table deletion
- `git push --force` / `git push -f` — force pushes
- `TRUNCATE` — SQL table truncation
- `DELETE FROM` without a `WHERE` clause — unqualified SQL deletes

## Installation

