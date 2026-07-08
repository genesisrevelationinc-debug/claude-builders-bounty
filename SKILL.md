# Generate Changelog Skill

A Claude Code skill to generate a structured `CHANGELOG.md` from git history.

## Commands

### `/generate-changelog`

Generates a `CHANGELOG.md` file by:
1. Finding the latest git tag
2. Fetching all commits since that tag
3. Auto-categorizing commits into: Added / Fixed / Changed / Removed
4. Writing a properly formatted `CHANGELOG.md`

## Usage

Run in Claude Code:
