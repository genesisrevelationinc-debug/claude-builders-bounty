# Claude Code Pre-Tool-Use Hook: Block Destructive Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code/) that intercepts and blocks dangerous bash commands before they execute.

## What It Blocks

| Pattern | Why It's Blocked |
|---------|----------------|
| `rm -rf` | Irreversible recursive deletion |
| `DROP TABLE` | Destroys entire database tables |
| `git push --force` | Overwrites remote git history |
| `TRUNCATE` | Wipes all table data (non-transactional) |
| `DELETE FROM` without `WHERE` | Deletes every row in a table |

## Installation (2 commands)

