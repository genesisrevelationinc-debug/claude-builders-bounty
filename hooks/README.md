# Pre-Tool-Use Hook: Block Destructive Bash Commands

A Claude Code `pre-tool-use` hook that intercepts and blocks dangerous bash commands before they can execute.

## What It Blocks

| Pattern | Example |
|---------|---------|
| `rm -rf` / `rm --force` | `rm -rf /` |
| `DROP TABLE` | `DROP TABLE users;` |
| `git push --force` | `git push origin main --force` |
| `TRUNCATE` | `TRUNCATE TABLE orders;` |
| `DELETE FROM` (no WHERE) | `DELETE FROM users;` |

## Installation

