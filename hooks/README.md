# Pre-Tool-Use Hook: Block Destructive Bash Commands

A Claude Code `pre-tool-use` hook that intercepts dangerous bash commands before they are executed, preventing accidental data loss.

## What It Blocks

| Pattern | Reason |
|---------|--------|
| `rm -rf` | Permanently deletes directories without confirmation |
| `git push --force` | Overwrites remote git history, potentially losing commits |
| `DROP TABLE` | Deletes entire database tables |
| `TRUNCATE` | Removes all data from a table |
| `DELETE FROM` (no WHERE) | Deletes all rows from a table |

## Installation

