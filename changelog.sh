#!/bin/bash
set -e

# Get the latest tag
LATEST_TAG=$(git describe --tags --abbrev=0)

# Get the commit hash of the latest tag
LATEST_TAG_COMMIT=$(git rev-list -n 1 $LATEST_TAG)

# Get the parent of the latest tag
LATEST_TAG_COMMIT_SHORT=$(git rev-list -n 1 $LATEST_TAG)

# Get the commit message of the latest tag
LATEST_TAG_COMMIT_MESSAGE=$(git show -s --format=%B $LATEST_TAG_COMMIT)

# Generate changelog
generate_changelog() {
    echo "# Changelog"
    echo
    echo "## [v1.0.0] - $(date +'%Y-%m-%d')"
    echo
    
    echo "### Added"
    echo
    echo "### Fixed"
    echo
    echo "### Changed"
    echo
    echo "### Removed"
    echo
}

