# Pre-Tool-Use Hook: Block Destructive Bash Commands

A Claude Code `pre-tool-use` hook that intercepts and blocks dangerous bash commands before they can execute.

## What It Blocks

| Pattern | Why It's Blocked |
|---------|-----------------|
| `rm -rf` | Irreversible recursive deletion |
| `DROP TABLE` | Destructive SQL — deletes table structure and data |
| `git push --force` | Overwrites remote history, can lose work |
| `TRUNCATE` | Removes all data from a table instantly |
| `DELETE FROM` (no WHERE) | Deletes all rows without a filter clause |

## Installation

