# Claude Code Pre-Tool-Use Hook: Block Destructive Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code) that intercepts and blocks dangerous bash commands before they execute.

## What It Blocks

| Pattern | Reason |
|---------|--------|
| `rm -rf` | Recursive force deletion |
| `DROP TABLE` | Database table deletion |
| `TRUNCATE` | Table data destruction |
| `DELETE FROM` without `WHERE` | Unconditional data deletion |
| `git push --force` | Overwrites remote history |

## Installation

