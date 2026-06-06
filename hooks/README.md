# Pre-Tool-Use Hook: Block Destructive Bash Commands

A Claude Code `pre-tool-use` hook that intercepts and blocks dangerous bash commands before they can be executed.

## What It Blocks

- `rm -rf` / `rm -fr` and variants
- `git push --force` / `git push -f`
- `DROP TABLE` SQL statements
- `TRUNCATE` SQL statements
- `DELETE FROM` without a `WHERE` clause

## Installation

