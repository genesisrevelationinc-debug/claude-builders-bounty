# Claude Code Pre-Tool-Use Security Hook

A `pre-tool-use` hook for Claude Code that intercepts and blocks dangerous bash commands before they can be executed.

## What It Blocks

| Pattern | Description |
|---------|-------------|
| `rm -rf` / `rm -r` / `rm -f` | Recursive/force file deletion |
| `DROP TABLE` | Destructive SQL — drops entire tables |
| `TRUNCATE` | Destructive SQL — removes all table data |
| `DELETE FROM` without `WHERE` | Destructive SQL — deletes all rows |
| `git push --force` / `git push -f` | Destructive git — overwrites remote history |

## Installation (2 commands)

