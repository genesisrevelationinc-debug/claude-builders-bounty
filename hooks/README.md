# Claude Code Pre-Tool-Use Hook: Block Destructive Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code) that intercepts and blocks dangerous bash commands before they execute.

## What It Blocks

| Pattern | Example |
|---------|---------|
| `rm -rf` | `rm -rf /important` |
| `DROP TABLE` | `DROP TABLE users` |
| `git push --force` | `git push --force origin main` |
| `TRUNCATE` | `TRUNCATE TABLE orders` |
| `DELETE FROM` (no WHERE) | `DELETE FROM users` |

## Installation (2 commands)

