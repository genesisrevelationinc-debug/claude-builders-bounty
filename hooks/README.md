# Claude Code Pre-Tool-Use Hook: Block Destructive Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code/) that intercepts and blocks dangerous bash commands before they execute.

## What It Blocks

- `rm -rf` and similar destructive remove commands
- `git push --force` / `git push -f`
- `DROP TABLE` SQL statements
- `TRUNCATE` SQL statements
- `DELETE FROM` without a `WHERE` clause

## Installation

