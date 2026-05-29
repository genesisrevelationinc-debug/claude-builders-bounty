# Destructive Command Blocker Hook

This hook blocks destructive bash commands like `rm -rf`, `DROP TABLE`, `git push --force`, `TRUNCATE`, and `DELETE FROM` without a WHERE clause.

## Installation

1. Create the file `~/.claude/hooks/pre_tool_use_hook.py`:

