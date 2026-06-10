# Claude Code Pre-Tool-Use Hook: Block Destructive Commands

A `pre-tool-use` hook for Claude Code that intercepts and blocks dangerous bash commands before they can execute.

## What It Blocks

- `rm -rf` and variants
- `DROP TABLE`
- `git push --force`
- `TRUNCATE`
- `DELETE FROM` without a `WHERE` clause

## Installation

