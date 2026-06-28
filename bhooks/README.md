# Pre-Tool-Use Hook: Block Destructive Bash Commands

A Claude Code `pre-tool-use` hook that intercepts dangerous bash commands before they are executed.

## What It Blocks

- `rm -rf` — recursive force removal
- `DROP TABLE` — database table deletion
- `git push --force` / `git push -f` — force pushing to remote
- `TRUNCATE` — table truncation
- `DELETE FROM` without a `WHERE` clause — unqualified row deletion

## Installation

