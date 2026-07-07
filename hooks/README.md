# Claude Code Pre-Tool-Use Hook: Block Destructive Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code) that intercepts and blocks dangerous bash commands before they execute.

## What It Blocks

| Pattern | Example | Why Blocked |
|---------|---------|-------------|
| `rm -rf` | `rm -rf /` | Irreversible data deletion |
| `DROP TABLE` | `DROP TABLE users;` | Irreversible schema destruction |
| `git push --force` | `git push --force origin main` | Overwrites remote history |
| `TRUNCATE` | `TRUNCATE TABLE orders;` | Bulk data deletion without logging |
| `DELETE FROM` (no WHERE) | `DELETE FROM users;` | Accidental full-table deletion |

## Installation (2 commands)

