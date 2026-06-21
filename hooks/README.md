# Pre-Tool-Use Hook: Block Destructive Bash Commands

A Claude Code `pre-tool-use` hook that intercepts and blocks dangerous bash commands before they can be executed.

## What It Blocks

| Pattern | Reason |
|---------|--------|
| `rm -rf` | Recursive force deletion |
| `DROP TABLE` | Destructive SQL operation |
| `git push --force` | Can overwrite remote history |
| `TRUNCATE` | Removes all table data |
| `DELETE FROM` without `WHERE` | Deletes all rows in a table |

## Installation

