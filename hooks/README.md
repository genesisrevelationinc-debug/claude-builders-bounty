# Claude Code Pre-Tool-Use Hook: Block Destructive Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code) that intercepts and blocks dangerous bash commands before they execute.

## What It Blocks

- `rm -rf` — recursive force deletion
- `DROP TABLE` — SQL table deletion
- `git push --force` / `git push -f` — force pushes
- `TRUNCATE` — SQL table truncation
- `DELETE FROM` without a `WHERE` clause

## Installation

