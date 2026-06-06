# Pre-Tool-Use Hook: Block Destructive Bash Commands

A Claude Code `pre-tool-use` hook that intercepts and blocks dangerous bash commands before they can execute.

## What It Blocks

- `rm -rf` and variants
- `DROP TABLE`
- `TRUNCATE`
- `git push --force` / `git push -f`
- `DELETE FROM` without a `WHERE` clause

## Installation

