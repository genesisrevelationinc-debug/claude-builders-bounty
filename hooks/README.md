# Pre-Tool-Use Hook: Block Destructive Bash Commands

A Claude Code `pre-tool-use` hook that intercepts and blocks dangerous bash commands before they can be executed.

## What It Blocks

| Pattern | Reason |
|---------|--------|
| `rm -rf` | Recursive force deletion |
| `DROP TABLE` | Irreversible table deletion |
| `git push --force` | Overwrites remote history |
| `TRUNCATE` | Wipes all table data |
| `DELETE FROM` (no WHERE) | Deletes all rows |

## Installation

