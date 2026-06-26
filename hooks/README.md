# Claude Code Pre-Tool-Use Hook: Block Destructive Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code) that intercepts and blocks dangerous bash commands before they can execute.

## What It Blocks

| Pattern | Description |
|---------|-------------|
| `rm -rf` | Recursive, force file deletion |
| `DROP TABLE` | SQL table deletion |
| `git push --force` | Force git push (overwrites remote history) |
| `TRUNCATE` | SQL table data wipe |
| `DELETE FROM` without `WHERE` | SQL deletion without filter |

## Install (2 commands)

