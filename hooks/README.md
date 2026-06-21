# Claude Code Pre-Tool-Use Hook: Block Destructive Bash Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code) that intercepts and blocks dangerous bash commands before they can be executed.

## What It Blocks

| Pattern | Description |
|---------|-------------|
| `rm -rf` | Recursive force delete |
| `DROP TABLE` | SQL table deletion |
| `git push --force` | Force push (overwrites remote history) |
| `TRUNCATE` | Removes all rows from a table |
| `DELETE FROM` without `WHERE` | Deletes all rows in a table |

## Installation

