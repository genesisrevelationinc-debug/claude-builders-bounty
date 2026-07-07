# Claude Code Pre-Tool-Use Hook: Block Destructive Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code/) that intercepts and blocks dangerous bash commands before they can execute.

## What It Blocks

| Pattern | Example | Why |
|---------|---------|-----|
| `rm -rf` | `rm -rf /important/data` | Irreversible file deletion |
| `DROP TABLE` | `DROP TABLE users;` | Deletes entire database tables |
| `TRUNCATE` | `TRUNCATE TABLE orders;` | Wipes all table data |
| `DELETE FROM` (no WHERE) | `DELETE FROM logs;` | Deletes all rows |
| `git push --force` | `git push --force origin main` | Overwrites remote history |

## Installation

