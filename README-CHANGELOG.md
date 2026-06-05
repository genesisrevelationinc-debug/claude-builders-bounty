# Changelog Generator

Automatically generate a structured `CHANGELOG.md` from your git history.

## Setup

1. Save `changelog.sh` to your project root
2. Make it executable: `chmod +x changelog.sh`
3. Run: `bash changelog.sh`

## How it works

- Finds commits since the last git tag
- Categorizes commits based on keywords in commit messages
- Outputs to `CHANGELOG.md`