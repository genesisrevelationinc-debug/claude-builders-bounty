# Pre-Tool-Use Hook: Block Destructive Bash Commands

A Claude Code `pre-tool-use` hook that intercepts and blocks dangerous bash commands before they execute.

## What It Blocks

| Pattern | Why Blocked |
|---------|-------------|
| `rm -rf` | Irreversible recursive deletion |
| `DROP TABLE` | Destructive SQL — deletes table + data |
| `git push --force` / `-f` | Overwrites remote history |
| `TRUNCATE` | Wipes all table data instantly |
| `DELETE FROM` without `WHERE` | Deletes all rows unintentionally |

## Installation

