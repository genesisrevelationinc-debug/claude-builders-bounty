# Claude Code Pre-Tool-Use Hook: Block Destructive Bash Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code/) that intercepts and blocks dangerous bash commands before they can execute.

## What It Blocks

| Pattern | Reason |
|---------|--------|
| `rm -rf` | Irreversible file deletion |
| `DROP TABLE` | Permanent database table removal |
| `git push --force` | Overwrites remote git history |
| `TRUNCATE` | Removes all table data without rollback |
| `DELETE FROM` (no `WHERE`) | Deletes all rows in a table |

## Installation

