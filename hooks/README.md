# Claude Code Pre-Tool-Use Hook: Block Destructive Bash Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code/hooks) that intercepts and blocks dangerous bash commands before they execute.

## What It Blocks

| Pattern | Reason |
|---------|--------|
| `rm -rf` | Prevents accidental recursive file deletion |
| `DROP TABLE` | Prevents SQL table destruction |
| `git push --force` | Prevents destructive remote history overwrite |
| `TRUNCATE` | Prevents SQL table data wipe |
| `DELETE FROM` without `WHERE` | Prevents accidental full-table deletion |

## Installation

