# Generate CHANGELOG from Git History

This skill automatically generates a structured CHANGELOG.md from a project's git history by analyzing commit messages since the last git tag.

## Features

- Works via `/generate-changelog` command
- Fetches commits since the last git tag
- Auto-categorizes into: `Added` / `Fixed` / `Changed` / `Removed`
- Outputs a properly formatted `CHANGELOG.md`

## Usage

To generate a changelog, simply run:

