# Claude Code Pre-Tool-Use Hook: Block Destructive Bash Commands

A `pre-tool-use` hook for [Claude Code](https://docs.anthropic.com/claude-code/) that intercepts and blocks dangerous bash commands before they can execute.

## What It Blocks

| Pattern | Reason |
|---------|--------|
| `rm -rf` / `rm -r` | Irreversible recursive deletion |
| `DROP TABLE` | Deletes entire database tables |
| `git push --force` | Overwrites remote git history |
| `TRUNCATE` | Removes all data from a table |
| `DELETE FROM` without `WHERE` | Deletes all rows from a table |

Blocked attempts are logged to `~/.claude/hooks/blocked.log` with a timestamp, command, and project path.

## Installation

