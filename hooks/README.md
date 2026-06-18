# Claude Code Hooks

Security hooks for Claude Code to prevent accidental destructive operations.

## Hooks

### `pre-tool-use`

Intercepts dangerous bash commands before they are executed by Claude Code.

**Blocks:**
- `rm -rf` — recursive force deletion
- `DROP TABLE` — SQL table deletion
- `git push --force` / `git push -f` — force push that overwrites remote history
- `TRUNCATE TABLE` — wipes all table data
- `DELETE FROM` without a `WHERE` clause — deletes all rows

**Logs blocked attempts to:** `~/.claude/hooks/blocked.log`

## Installation

