# Claude Code Pre-Tool-Use Hook: Block Destructive Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code/) that intercepts and blocks dangerous bash commands before they execute.

## What It Blocks

| Pattern | Reason |
|---------|--------|
| `rm -rf` | Recursive force deletion |
| `DROP TABLE` | Destructive SQL operation |
| `git push --force` / `git push -f` | Force push overwrites remote history |
| `TRUNCATE` | Unconditional table data removal |
| `DELETE FROM` without `WHERE` | Unconditional row deletion |

## Installation (2 commands)

