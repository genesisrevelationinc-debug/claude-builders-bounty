# Claude Code Pre-Tool-Use Hook: Block Destructive Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code) that intercepts and blocks dangerous bash commands before they execute.

## What It Blocks

| Pattern | Why |
|---------|-----|
| `rm -rf` | Irreversible recursive deletion |
| `DROP TABLE` | Permanent table deletion |
| `git push --force` | Overwrites remote history |
| `TRUNCATE` | Unrecoverable data removal |
| `DELETE FROM` (no `WHERE`) | Deletes all table rows |

## Installation

