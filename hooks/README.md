# Claude Code Pre-Tool-Use Hook: Block Destructive Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code/) that intercepts and blocks dangerous bash commands before they execute.

## What It Blocks

| Pattern | Why It's Blocked |
|---------|----------------|
| `rm -rf` | Recursively and forcefully deletes files/directories |
| `DROP TABLE` | Permanently deletes database tables |
| `git push --force` | Overwrites remote history, potentially losing work |
| `TRUNCATE` | Quickly removes all table rows (non-transactional in many DBs) |
| `DELETE FROM` without `WHERE` | Deletes all rows from a table |

## Installation

