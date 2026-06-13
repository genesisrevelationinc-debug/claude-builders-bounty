# Pre-Tool-Use Hook: Block Destructive Bash Commands

A Claude Code `pre-tool-use` hook that intercepts and blocks dangerous bash commands before they can be executed.

## What It Blocks

| Pattern | Reason |
|---------|--------|
| `rm -rf` | Recursive force deletion of files/directories |
| `DROP TABLE` | Permanent deletion of database tables |
| `git push --force` | Overwrites remote git history |
| `TRUNCATE` | Complete removal of table data |
| `DELETE FROM` without `WHERE` | Deletes all rows in a table |

## Installation

