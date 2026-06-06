# Claude Code Pre-Tool-Use Hook: Block Destructive Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code/) that intercepts and blocks dangerous bash commands before they can execute.

## What It Blocks

| Pattern | Reason |
|---------|--------|
| `rm -rf`, `rm -r`, `rm -f` | Prevents recursive/force file deletion |
| `DROP TABLE` | Prevents database table deletion |
| `git push --force` | Prevents force pushes to remote |
| `TRUNCATE` | Prevents table data removal |
| `DELETE FROM` without `WHERE` | Prevents unconditional row deletion |

## Installation

