# Claude Code Pre-Tool-Use Hook: Block Destructive Commands

A safety hook for [Claude Code](https://docs.anthropic.com/claude-code/) that intercepts and blocks dangerous bash commands before they execute.

## What It Blocks

| Pattern | Why |
|---------|-----|
| `rm -rf` | Recursive force deletion |
| `DROP TABLE` | Destructive SQL schema change |
| `TRUNCATE` | Unqualified table data removal |
| `DELETE FROM` without `WHERE` | Accidental full-table deletion |
| `git push --force` / `git push -f` | Overwriting remote git history |

## Installation

