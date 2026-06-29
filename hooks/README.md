# Claude Code Pre-Tool-Use Hook: Block Destructive Bash Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code) that intercepts and blocks dangerous bash commands before they execute.

## What It Blocks

| Pattern | Why It's Blocked |
|---------|----------------|
| `rm -rf` | Irreversible mass deletion |
| `DROP TABLE` | Permanent table deletion |
| `git push --force` | Overwrites remote history |
| `TRUNCATE` | Wipes all table data |
| `DELETE FROM` without `WHERE` | Deletes all rows unintentionally |

## Installation

