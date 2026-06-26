# Claude Code Pre-Tool-Use Hook: Block Destructive Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code) that intercepts and blocks dangerous bash commands before they execute.

## What It Blocks

| Pattern | Reason |
|---------|--------|
| `rm -rf` | Recursive, force deletion of files/directories |
| `DROP TABLE` | Permanent deletion of database tables |
| `git push --force` | Overwrites remote history, can lose work |
| `TRUNCATE` | Irreversible removal of all table data |
| `DELETE FROM` without `WHERE` | Unqualified deletion of all rows |

## Installation

