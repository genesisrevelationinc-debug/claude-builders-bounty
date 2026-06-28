# Claude Code Pre-Tool-Use Hook: Block Destructive Bash Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code) that intercepts and blocks dangerous bash commands before they execute.

## What It Blocks

| Pattern | Example | Why It's Blocked |
|---------|---------|----------------|
| `rm -rf` | `rm -rf /` | Irreversible mass deletion |
| `DROP TABLE` | `DROP TABLE users;` | Destroys entire tables |
| `git push --force` | `git push --force origin main` | Overwrites remote history |
| `TRUNCATE` | `TRUNCATE TABLE orders;` | Instant, unlogged data wipe |
| `DELETE FROM` (no WHERE) | `DELETE FROM users;` | Deletes all rows accidentally |

## Installation (2 commands)

