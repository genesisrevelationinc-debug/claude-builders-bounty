# Claude Code Pre-Tool-Use Hook: Block Destructive Commands

A security hook for Claude Code that intercepts and blocks dangerous bash commands before they can execute.

## What It Blocks

- `rm -rf` and `rm -f` (force removal)
- `git push --force` and `git push -f`
- `DROP TABLE` (SQL)
- `TRUNCATE` (SQL)
- `DELETE FROM` without a `WHERE` clause (SQL)

## Installation

