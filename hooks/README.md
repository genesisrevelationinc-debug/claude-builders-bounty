# Claude Code Pre-Tool-Use Security Hook

A `pre-tool-use` hook for [Claude Code](https://docs.anthropic.com/claude-code) that intercepts and blocks destructive bash commands before they can execute.

## What It Blocks

| Pattern | Reason |
|---------|--------|
| `rm -rf` | Recursive force deletion |
| `DROP TABLE` | Database table deletion |
| `git push --force` | Force push to remote |
| `TRUNCATE` | Table data deletion |
| `DELETE FROM` without `WHERE` | Unqualified row deletion |

## Installation

