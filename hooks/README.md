# Pre-Tool-Use Hook: Block Destructive Bash Commands

A Claude Code `pre-tool-use` hook that intercepts and blocks dangerous bash commands before they execute.

## What It Blocks

- `rm -rf` / `rm -rf *`
- `DROP TABLE`
- `git push --force` / `git push -f`
- `TRUNCATE`
- `DELETE FROM` without a `WHERE` clause

## Installation

