# Pre-Tool-Use Hook: Block Destructive Bash Commands

A Claude Code `pre-tool-use` hook that intercepts and blocks dangerous bash commands before they can execute.

## What It Blocks

| Pattern | Reason |
|---------|--------|
| `rm -rf` | Recursive force deletion of files/directories |
| `DROP TABLE` | Destructive SQL — deletes entire tables |
| `TRUNCATE` | Destructive SQL — wipes table data |
| `DELETE FROM` without `WHERE` | Unqualified delete — removes all rows |
| `git push --force` | Overwrites remote git history |

## Installation (2 commands)

