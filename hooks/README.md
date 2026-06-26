# Claude Code Pre-Tool-Use Hook: Block Destructive Bash Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code) that intercepts and blocks dangerous bash commands before they can execute.

## What It Blocks

- `rm -rf` — recursive force deletion
- `DROP TABLE` — SQL table deletion
- `git push --force` / `git push -f` — force git push
- `TRUNC — SQL table truncation
- `DELETE FROM` without a `WHERE` clause

## Installation

