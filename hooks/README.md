# Destructive Command Blocker Hook

## Installation

1. Copy the `pre-tool-use` script to `~/.claude/hooks/pre-tool-use`
2. Make it executable: `chmod +x ~/.claude/hooks/pre-tool-use`

## What it blocks
- `rm -rf` and variants like `rm -r /`
- `DROP TABLE`, `TRUNCATE`, `DELETE FROM` without WHERE clause, and `git push --force`