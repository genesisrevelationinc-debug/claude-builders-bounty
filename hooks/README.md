# Claude Code Pre-Tool-Use Hook: Block Destructive Bash Commands

A `pre-tool-use` hook for [Claude Code](https://docs.anthropic.com/claude-code) that intercepts and blocks dangerous bash commands before they can execute.

## What it blocks

| Pattern | Reason |
|---------|--------|
| `rm -rf` | Irreversible recursive deletion |
| `DROP TABLE` | Permanent table deletion |
| `git push --force` | Overwrites remote history |
| `TRUNCATE` | Wipes all table data instantly |
| `DELETE FROM` (without `WHERE`) | Deletes all rows in a table |

Blocked attempts are logged to `~/.claude/hooks/blocked.log` with a timestamp, the attempted command, and the project path.

## Installation

