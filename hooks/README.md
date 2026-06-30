# Pre-Tool-Use Hook: Block Destructive Bash Commands

A Claude Code `pre-tool-use` hook that intercepts and blocks dangerous bash commands before they can execute.

## What It Blocks

| Pattern | Example |
|---------|---------|
| `rm -rf` / recursive delete | `rm -rf /important/data` |
| `DROP TABLE` | `DROP TABLE users;` |
| `TRUNCATE` | `TRUNCATE TABLE logs;` |
| `DELETE FROM` without `WHERE` | `DELETE FROM users;` |
| `git push --force` | `git push --force origin main` |

## Installation

