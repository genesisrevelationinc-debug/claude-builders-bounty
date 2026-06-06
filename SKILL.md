# Generate Changelog

This skill generates a structured CHANGELOG.md file from git history, organizing commit messages into categories like Added, Fixed, Changed, and Removed.

## Installation

1. Clone this repository
2. Navigate to the project directory
3. Make the script executable: `chmod +x changelog.sh`

## Usage

Run the script with: `./changelog.sh`

## How it works

This script automatically:
- Identifies the latest git tag
- Retrieves all commits since that tag
- Categorizes commits based on their prefixes
- Generates a structured CHANGELOG.md file

## Configuration

No configuration is needed. The script uses conventional commit messages to categorize changes.

## Code

