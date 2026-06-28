# Claude Code Pre-Tool-Use Hook: Block Destructive Commands

A security hook for Claude Code that intercepts and blocks dangerous bash commands before they can be executed.

## What It Blocks

- `rm -rf` — recursive/force file removal
- `DROP TABLE` — destructive SQL operation
- `git push --force` / `git push -f` — force push to remote
- `TRUNCATE` — destructive SQL operation
- `DELETE FROM` without a `WHERE` clause — unconditional SQL deletion

## Installation

