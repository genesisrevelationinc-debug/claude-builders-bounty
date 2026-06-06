# Claude Code Pre-Tool-Use Hook: Block Destructive Bash Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code) that intercepts and blocks dangerous bash commands before they execute.

## What It Blocks

| Pattern | Example |
|---------|---------|
| `rm -rf` | `rm -rf /important` |
| `DROP TABLE` | `DROP TABLE users;` |
| `TRUNCATE` | `TRUNCATE TABLE orders;` |
| `DELETE FROM` (no WHERE) | `DELETE FROM logs;` |
| `git push --force` | `git push --force origin main` |

## Installation

