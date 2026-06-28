# Pre-Tool-Use Hook: Block Destructive Bash Commands

A Claude Code `pre-tool-use` hook that intercepts and blocks dangerous bash commands before they can be executed.

## What It Blocks

| Pattern | Reason |
|---------|--------|
| `rm -rf` | Recursive force deletion |
| `DROP TABLE` | Deletes entire database table |
| `git push --force` | Overwrites remote git history |
| `TRUNCATE` | Removes all data from a table |
| `DELETE FROM` without `WHERE` | Deletes all rows from a table |

## Installation

