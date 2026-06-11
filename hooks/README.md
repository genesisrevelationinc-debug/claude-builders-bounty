# Pre-Tool-Use Hook: Block Destructive Bash Commands

A Claude Code `pre-tool-use` hook that intercepts dangerous bash commands before they are executed, preventing accidental data loss.

## What It Blocks

| Pattern | Example | Why It's Blocked |
|---------|---------|----------------|
| `rm -rf` | `rm -rf /important/data` | Irreversible recursive deletion |
| `DROP TABLE` | `DROP TABLE users` | Deletes entire database tables |
| `git push --force` | `git push --force origin main` | Overwrites remote history |
| `TRUNCATE` | `TRUNCATE TABLE orders` | Deletes all table data instantly |
| `DELETE FROM` (no WHERE) | `DELETE FROM users` | Deletes all rows without filtering |

## Installation

