# Claude Code Pre-Tool-Use Hook: Block Destructive Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code) that intercepts and blocks dangerous bash commands before they can execute.

## What It Blocks

| Pattern | Why It's Blocked |
|---------|-----------------|
| `rm -rf` | Permanently deletes files and directories without confirmation |
| `DROP TABLE` | Destroys entire database tables |
| `git push --force` | Overwrites remote git history, potentially losing work |
| `TRUNCATE` | Removes all data from a table instantly |
| `DELETE FROM` without `WHERE` | Deletes every row in a table |

## Installation

