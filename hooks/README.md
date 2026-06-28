# Block Destructive Commands Hook

A Claude Code `pre-tool-use` hook that intercepts and blocks dangerous bash commands before they can be executed.

## What It Blocks

| Pattern | Example | Why Blocked |
|---------|---------|-------------|
| `rm -rf` | `rm -rf /important` | Irreversible file deletion |
| `DROP TABLE` | `DROP TABLE users` | Irreversible data loss |
| `TRUNCATE` | `TRUNCATE orders` | Mass data deletion |
| `DELETE FROM` (no WHERE) | `DELETE FROM users` | Accidental full table wipe |
| `git push --force` | `git push --force origin main` | Overwrites remote history |

## Installation

