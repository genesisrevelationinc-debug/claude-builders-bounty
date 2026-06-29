# Pre-Tool-Use Hook: Block Destructive Bash Commands

A Claude Code `pre-tool-use` hook that intercepts and blocks dangerous bash commands before they are executed.

## What It Blocks

| Pattern | Reason |
|---------|--------|
| `rm -rf` | Recursive file deletion can destroy data |
| `DROP TABLE` | Permanently deletes database tables |
| `git push --force` | Overwrites remote history, causing data loss |
| `TRUNCATE` | Removes all data from a table instantly |
| `DELETE FROM` without `WHERE` | Deletes all rows from a table |

## Installation

