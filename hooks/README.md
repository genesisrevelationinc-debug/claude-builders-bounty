# Pre-Tool-Use Hook: Block Destructive Bash Commands

A Claude CodeDivider Code `pre-tool-use` hook that intercepts and blocks dangerous bash commands before they can execute.

## What It Blocks

- `rm -rf` and similar recursive force deletes
- `DROP TABLE` SQL statements
- `git push --force` / `git push -f`
- `TRUNCATE` statements
- `DELETE FROM` without a `WHERE` clause

## Installation

