# Claude Code Pre-Tool-Use Hook: Block Destructive Bash Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code) that intercepts and blocks dangerous bash commands before they can execute.

## What It Blocks

| Pattern | Reason |
|---------|--------|
| `rm -rf` | Recursive, forceful file deletion |
| `DROP TABLE` | Permanent table deletion |
| `git push --force` | Overwrites remote git history |
| `TRUNCATE` | Irreversible table wipe |
| `DELETE FROM` (no `WHERE`) | Deletes all table rows |

## Installation

