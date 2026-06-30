# Claude Code Pre-Tool-Use Security Hook

A security hook for Claude Code that intercepts and blocks destructive bash commands before they can execute.

## What It Blocks

| Pattern | Example |
|---------|---------|
| `rm -rf` | `rm -rf /important/data` |
| `DROP TABLE` | `DROP TABLE users;` |
| `git push --force` | `git push --force origin main` |

## Installation

