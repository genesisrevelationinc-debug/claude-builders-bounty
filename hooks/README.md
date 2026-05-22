# Pre-Tool-Use Hook: Block Destructive Bash Commands

A Claude Code `pre-tool-use` hook that intercepts and blocks dangerous bash commands before they can execute.

## What It Blocks

| Pattern | Reason |
|---------|--------|
| `rm -rf` | Recursive force deletion of files/directories |
| `DROP TABLE` | Database table deletion |
| `git push --force` | Force push to remote (overwrites history) |
| `TRUNCATE` | Bulk table data deletion |
| `DELETE FROM` without `WHERE` | Unconditional row deletion |

## Installation

