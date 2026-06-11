# Claude Code Pre-Tool-Use Hook: Block Destructive Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code) that intercepts and blocks dangerous bash commands before they can execute.

## What It Blocks

| Pattern | Example | Why |
|---------|---------|-----|
| `rm -rf` | `rm -rf /` | Irreversible mass deletion |
| `DROP TABLE` | `DROP TABLE users` | Destroys database schema |
| `git push --force` | `git push --force origin main` | Overwrites remote history |
| `TRUNCATE` | `TRUNCATE TABLE orders` | Deletes all table data instantly |
| `DELETE FROM` (no WHERE) | `DELETE FROM users` | Deletes all rows accidentally |

## Installation

