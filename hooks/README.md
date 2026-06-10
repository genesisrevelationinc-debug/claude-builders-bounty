# Claude Code Pre-Tool-Use Hook: Block Destructive Commands

A security hook for Claude Code that intercepts and blocks dangerous bash commands before they can execute.

## What It Blocks

- `rm -rf` — recursive force deletion
- `DROP TABLE` — database table deletion
- `git push --force` — force push that overwrites remote history
- `TRUNCATE` — removes all rows from a table
- `DELETE FROM` without a `WHERE` clause — unfiltered row deletion

## Installation

