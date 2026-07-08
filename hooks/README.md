# Pre-Tool-Use Hook: Block Destructive Bash Commands

A Claude Code `pre-tool-use` hook that intercepts and blocks dangerous bash commands before they can be executed.

## What It Blocks

| Pattern | Reason |
|---------|--------|
| `rm -rf` | Irreversible mass deletion |
| `DROP TABLE` | Destructive SQL |
| `TRUNCATE` | Destructive SQL |
| `DELETE FROM` without `WHERE` | Accidental data loss |
| `git push --force` / `git push -f` | Overwrites remote history |

## Installation

