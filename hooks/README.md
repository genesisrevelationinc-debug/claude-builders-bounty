# Claude Code Pre-Tool-Use Hook: Block Destructive Bash Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code/) that intercepts and blocks dangerous bash commands before they execute.

## What It Blocks

| Pattern | Why It's Blocked |
|---------|-----------------|
| `rm -rf` | Recursive force deletion of files/directories |
| `DROP TABLE` | Deletes entire database tables |
| `git push --force` | Overwrites remote git history |
| `TRUNCATE` | Removes all rows from a table |
| `DELETE FROM` without `WHERE` | Deletes all rows from a table |

## Installation

