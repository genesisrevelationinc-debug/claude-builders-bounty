# Pre-Tool-Use Hook: Block Destructive Bash Commands

A Claude Code `pre-tool-use` hook that intercepts dangerous bash commands before they are executed.

## What it blocks

- `rm -rf` — recursive force deletion
- `DROP TABLE` — dropping database tables
- `git push --force` — force pushing to git
- `TRUNCATE TABLE` — truncating database tables
- `DELETE FROM` without a `WHERE` clause — deleting all rows

## Installation

