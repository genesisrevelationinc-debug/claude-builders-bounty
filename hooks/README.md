# Claude Code Pre-Tool-Use Hook: Block Destructive Bash Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code) that intercepts and blocks dangerous bash commands before they execute.

## What It Blocks

| Pattern | Example | Why |
|---------|---------|-----|
| `rm -rf` | `rm -rf /important` | Prevents recursive force deletion |
| `DROP TABLE` | `DROP TABLE users` | Prevents table deletion |
| `git push --force` | `git push --force origin main` | Prevents history overwrite |
| `TRUNCATE` | `TRUNCATE TABLE orders` | Prevents data truncation |
| `DELETE FROM` (no WHERE) | `DELETE FROM users` | Prevents deleting all rows |

## Installation (2 commands)

