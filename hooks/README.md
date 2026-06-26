# Claude Code Pre-Tool-Use Hook: Block Destructive Bash Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code/) that intercepts and blocks dangerous bash commands before they execute.

## What It Blocks

| Pattern | Why It's Blocked |
|---------|-----------------|
| `rm -rf` | Recursive force deletion destroys files irreversibly |
| `DROP TABLE` | Permanently deletes database tables |
| `TRUNCATE` | Rapidly removes all table data, often non-transactional |
| `DELETE FROM` (no `WHERE`) | Deletes all rows without a filter clause |
| `git push --force` | Overwrites remote git history, causing team data loss |

## Installation (2 commands)

