# Pre-Tool-Use Hook: Block Destructive Bash Commands

A Claude Code `pre-tool-use` hook that intercepts and blocks dangerous bash commands before they can be executed.

## What It Blocks

| Pattern | Why It's Blocked |
|---------|-----------------|
| `rm -rf` | Forcefully and recursively removes files/directories |
| `DROP TABLE` | Deletes an entire database table and all its data |
| `git push --force` | Forcefully overwrites remote git history, potentially destroying others' work |
| `TRUNCATE` | Quickly removes all rows from a table (cannot be rolled back in some DBs) |
| `DELETE FROM` without `WHERE` | Deletes all rows from a table without filtering |

## Installation

