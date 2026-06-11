# Pre-Tool-Use Hook: Block Destructive Bash Commands

A Claude Code `pre-tool-use` hook that intercepts and blocks dangerous bash commands before they are executed.

## What It Blocks

| Pattern | Reason |
|---------|--------|
| `rm -rf`, `rm -r`, `rm -f` | Destructive file/directory removal |
| `DROP TABLE` | Database table deletion |
| `git push --force` / `git push -f` | Destructive force push to remote |
| `TRUNCATE` | Table data destruction |
| `DELETE FROM` without `WHERE` | Accidental full-table deletion |

## Installation

