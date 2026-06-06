# Generate Changelog

This skill automatically generates a structured CHANGELOG.md from your project's git history.

## Usage

Type `/generate-changelog` to create an updated changelog based on commits since the last git tag.

## Features

- Fetches commits since the last git tag
- Auto-categorizes changes into Added, Fixed, Changed, and Removed sections
- Outputs a properly formatted CHANGELOG.md file

## How it works

1. The skill runs `git describe` to find the last tag
2. Gets commit messages since that tag with `git log`
3. Categorizes commits based on keywords in the commit message
4. Generates a CHANGELOG.md file in the current directory

## Requirements

- Git must be installed and the project must be a Git repository with tags
- The project should use [Conventional Commits](https://www.conformantcommits.org) for best results

This skill was generated as a response to bounty #1.