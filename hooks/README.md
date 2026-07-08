# Pre-Tool-Use Hook: Block Destructive Bash Commands

A Claude Code `pre-tool-use` hook that intercepts and blocks dangerous bash commands before they can be executed.

## What It Blocks

| Pattern | Reason |
|---------|--------|
| `rm -rf` | Irreversible recursive deletion |
| `DROP TABLE` | Deletes entire database table |
| `TRUNCATE` | Removes all data from table |
| `DELETE FROM` without `WHERE` | Deletes all rows |
| `git push --force` | Overwrites remote git history |

## Installation (2 commands)

