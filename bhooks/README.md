# Claude Code Pre-Tool-Use Hook: Block Destructive Commands

A security hook for Claude Code that intercepts and blocks dangerous bash commands before they execute.

## What It Blocks

- `rm -rf` — Recursive force delete
- `DROP TABLE` — Database table deletion
- `git push --force` — Force push (can overwrite history)
- `TRUNCATE` — Removes all rows from a table
- `DELETE FROM` without a `WHERE` clause — Deletes all rows

## Installation (2 commands)

