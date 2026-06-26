# Claude Code Pre-Tool-Use Hook: Block Destructive Bash Commands

A security hook for Claude Code that intercepts and blocks dangerous bash commands before they can execute.

## What it blocks

- `rm -rf` — recursive force deletion
- `DROP TABLE` — SQL table deletion
- `git push --EXTEND` — force push to git remote
- `TRUNCATE` — SQL table truncation
- `DELETE FROM` without a `WHERE` clause — unqualified SQL deletion

## Installation

