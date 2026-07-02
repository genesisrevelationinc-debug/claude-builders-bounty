# Pre-Tool-Use Hook: Block Destructive Bash Commands

A Claude Code `pre-tool-use` hook that intercepts and blocks dangerous bash commands before they can be executed.

## What It Blocks

| Pattern | Why It's Blocked |
|---------|---------------|
| `rm -rf` | Recursive force delete destroys directories irreversibly |
| `DROP TABLE` | Deletes entire database tables and all their data |
| `git push --force` | Overwrites remote git history, potentially losing commits |
| `TRUNCATE` | Removes all table rows without individual row logging |
| `DELETE FROM` without `WHERE` | Deletes all rows in a table |

## Installation

