# Claude Code Pre-Tool-Use Hook: Block Destructive Bash Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code) that intercepts and blocks dangerous bash commands before they can execute.

## What It Blocks

| Pattern | Why It's Blocked |
|---------|---------------|
| `rm -rf` | Irreversibly deletes entire directories |
| `DROP TABLE` | Permanently deletes database tables |
| `git push --force` | Overwrites remote git history |
| `TRUNCATE` | Removes all table data instantly |
| `DELETE FROM` (no `WHERE`) | Deletes all rows in a table |

## Installation

