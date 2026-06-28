# Pre-Tool-Use Hook: Block Destructive Bash Commands

A Claude Code `pre-tool-use` hook that intercepts and blocks dangerous bash commands before they can execute.

## What It Blocks

| Pattern | Reason |
|---------|--------|
| `rm -rf` | Irreversible recursive deletion |
| `DROP TABLE` | Destructive SQL — drops entire table |
| `git push --force` | Overwrites remote git history |
| `TRUNCATE` | Destructive SQL — removes all rows |
| `DELETE FROM` without `WHERE` | Deletes all rows in a table |

## Installation (2 commands)

