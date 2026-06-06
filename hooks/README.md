# Claude Code Pre-Tool-Use Hook: Block Destructive Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code) that intercepts and blocks dangerous bash commands before they can execute.

## What It Blocks

| Pattern | Why |
|---------|-----|
| `rm -rf` | Irreversible mass deletion |
| `DROP TABLE` | Database table destruction |
| `git push --force` | Overwriting remote git history |
| `TRUNCATE` | Wiping table data |
| `DELETE FROM` without `WHERE` | Deleting all table rows |

## Install (2 commands)

