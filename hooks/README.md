# Claude Code Pre-Tool-Use Hook: Block Destructive Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code) that intercepts and blocks dangerous bash commands before they execute.

## What It Blocks

| Pattern | Why It's Blocked |
|---------|---------------|
| `rm -rf` | Irreversible recursive deletion |
| `DROP TABLE` | Deletes entire database tables |
| `git push --force` | Overwrites remote git history |
| `TRUNCATE` | Removes all rows from a table |
| `DELETE FROM` (no `WHERE`) | Deletes all rows without filtering |

## Installation

