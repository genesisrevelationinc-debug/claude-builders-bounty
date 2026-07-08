# Claude Code Pre-Tool-Use Hook: Block Destructive Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code) that intercepts and blocks dangerous bash commands before they can execute.

## What It Blocks

| Pattern | Why It's Blocked |
|---------|----------------|
| `rm -rf` | Irreversible directory deletion |
| `DROP TABLE` | Permanent table removal |
| `git push --force` | Overwrites remote git history |
| `TRUNCATE` | Deletes all table rows instantly |
| `DELETE FROM` (no `WHERE`) | Deletes all rows accidentally |

## Installation

