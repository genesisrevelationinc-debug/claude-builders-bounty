# Claude Code Pre-Tool-Use Hook: Block Destructive Bash Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code/) that intercepts and blocks dangerous bash commands before they can execute.

## What It Blocks

| Pattern | Reason |
|---------|--------|
| `rm -rf` | Recursive, forceful deletion without confirmation |
| `DROP TABLE` | Permanent deletion of database tables |
| `git push --force` | Overwrites remote git history |
| `TRUNCATE` | Fast, unlogged deletion of all table data |
| `DELETE FROM` (no `WHERE`) | Deletes all rows in a table |

## Installation

