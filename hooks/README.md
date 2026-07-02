# Block Destructive Commands Hook

A Claude Code `pre-tool-use` hook that intercepts dangerous bash commands before they are executed.

## What it blocks

- `rm -rf` / `rm -fr` and variations
- `git push --force` / `git push -f`
- `DROP TABLE` / `DROP DATABASE`
- `TRUNCATE TABLE`
- `DELETE FROM` without a `WHERE` clause

## Installation

