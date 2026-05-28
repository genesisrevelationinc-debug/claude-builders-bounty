# Pre-Tool-Use Hook: Block Destructive Bash Commands

A Claude Code `pre-tool-use` hook that intercepts and blocks dangerous bash commands before they can execute.

## What It Blocks

| Pattern | Reason |
|---------|--------|
| `rm -rf` | Recursive force deletion |
| `DROP TABLE` | Database table deletion |
| `git push --force` / `git push -f` | Force push overwrites remote history |
| `TRUNCATE` | Table data removal |
| `DELETE FROM` without `WHERE` | Unconditional row deletion |

## Installation

