# Generate Changelog Skill

Generate a structured `CHANGELOG.md` from git history using `/generate-changelog`.

## Setup

1. Copy this `SKILL.md` into your project root.
2. Run `/generate-changelog` in Claude Code.
3. Check the generated `CHANGELOG.md`.

## Commands

### `/generate-changelog`

Generates a `CHANGELOG.md` with commits since the last git tag, auto-categorized into Added / Fixed / Changed / Removed.

**Workflow:**

1. Detect the latest git tag.
2. Fetch commits since that tag: `git log <tag>..HEAD --pretty=format:"%h %s"`.
3. Categorize each commit:
   - **Added**: feat, add, introduce, implement, new
   - **Fixed**: fix, bugfix, hotfix, repair, resolve, patch
   - **Changed**: update, modify, change, refactor, improve, optimize, upgrade
   - **Removed**: remove, delete, drop, deprecate, clean
4. Generate `CHANGELOG.md` with proper formatting.
5. If no tags exist, use all commits.

**Example output:**

