# Claude Code Pre-Tool-Use Hook: Block Destructive Commands

A safety hook for [Claude Code](https://docs.anthropic.com/claude-code) that intercepts and blocks dangerous bash commands before they execute.

## What It Blocks

| Pattern | Why |
|---------|-----|
| `rm -rf` | Recursive force delete |
| `DROP TABLE` | Deletes entire table |
| `TRUNCATE` | Removes all table data |
| `DELETE FROM` without `WHERE` | Deletes all rows |
| `git push --force` / `git push -f` | Overwrites remote history |

## Installation

