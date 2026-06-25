# Claude Code Pre-Tool-Use Hook: Block Destructive Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code/) that intercepts and blocks dangerous bash commands before they can execute.

## What It Blocks

| Pattern | Example | Risk |
|---------|---------|------|
| `rm -rf` | `rm -rf /important/data` | Irreversible data deletion |
| `DROP TABLE` | `DROP TABLE users;` | Database table destruction |
| `git push --force` | `git push --force origin main` | Overwrites remote history |
| `TRUNCATE` | `TRUNCATE TABLE orders;` | Bulk data removal |
| `DELETE FROM` (no WHERE) | `DELETE FROM users;` | Unconditional row deletion |

## Installation

