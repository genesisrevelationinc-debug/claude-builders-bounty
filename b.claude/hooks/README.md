# Claude Code Pre-Tool-Use Hook: Block Destructive Bash Commands

A `pre-tool-use` hook for [Claude Code](https://docs.anthropic.com/claude-code/hooks) that intercepts and blocks dangerous bash commands before they are executed.

## What it blocks

- `rm -rf` / `rm -r` / `rm -f` (destructive recursive/force delete)
- `DROP TABLE` (SQL table deletion)
- `git push --force` / `git push -f` (force push)
- `TRUNCATE` (SQL table truncation)
- `DELETE FROM` without a `WHERE` clause (SQL mass deletion)

## Installation

