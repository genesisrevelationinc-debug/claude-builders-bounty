# Claude Code Pre-Tool-Use Hook: Block Destructive Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code/) that intercepts and blocks dangerous bash commands before they can be executed.

## What It Blocks

| Pattern | Reason |
|---------|--------|
| `rm -rf` | Recursive force deletion |
| `DROP TABLE` | Database table deletion |
| `git push --force` | Force push to remote |
| `TRUNCATE` | Table data removal |
| `DELETE FROM` without `WHERE` | Unconditional data deletion |

## Installation

