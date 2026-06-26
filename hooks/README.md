# Pre-Tool-Use Hook: Block Destructive Bash Commands

A Claude Code `pre-tool-use` hook that intercepts and blocks dangerous bash commands before they can execute.

## What It Blocks

| Pattern | Why It's Blocked |
|---------|----------------|
| `rm -rf` | Irreversibly deletes files and directories |
| `DROP TABLE` | Permanently removes database tables |
| `git push --force` | Overwrites remote git history |
| `TRUNCATE` | Removes all table data without row-level logging |
| `DELETE FROM` (no `WHERE`) | Deletes all rows in a table |

## Installation

