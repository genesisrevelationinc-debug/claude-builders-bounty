# Claude Code Pre-Tool-Use Hook: Block Destructive Commands

A security hook for Claude Code that intercepts and blocks dangerous bash commands before they can execute.

## What It Blocks

| Pattern | Why It's Blocked |
|---------|---------------|
| `rm -rf` | Permanently deletes directories and files without confirmation |
| `DROP TABLE` | Destructively removes database tables |
| `git push --force` | Overwrites remote git history, potentially losing work |
| `TRUNCATE` | Removes all data from a table without row-level logging |
| `DELETE FROM` without `WHERE` | Deletes all rows in a table |

## Installation (2 commands)

