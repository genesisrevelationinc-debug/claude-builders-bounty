# Claude Code Pre-Tool-Use Hook: Block Destructive Bash Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code/) that intercepts and blocks dangerous bash commands before they can be executed.

## What It Blocks

| Pattern | Reason |
|---------|--------|
| `rm -rf` | Prevents accidental recursive deletion of directories |
| `DROP TABLE` | Prevents accidental SQL table deletion |
| `git push --force` | Prevents accidental overwrite of remote git history |
| `TRUNCATE` | Prevents accidental SQL data deletion |
| `DELETE FROM` without `WHERE` | Prevents accidental deletion of all table rows |

## Installation

