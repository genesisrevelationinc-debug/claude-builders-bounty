# Claude Code Pre-Tool-Use Hook: Block Destructive Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code) that intercepts and blocks dangerous bash commands before they can execute.

## What It Blocks

| Pattern | Why It's Blocked |
|---------|----------------|
| `rm -rf` / `rm -r` / `rm -f` | Irreversible file deletion |
| `DROP TABLE` | Deletes entire database tables |
| `git push --force` / `git push -f` | Overwrites remote git history |
| `TRUNCATE` | Removes all table data without logging |
| `DELETE FROM` without `WHERE` | Deletes all rows in a table |

## Installation

