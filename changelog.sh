#!/bin/bash

# Get the last tag or use the initial commit if no tags exist
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null)
if [ -z "$LAST_TAG" ]; then
    LAST_TAG=$(git rev-list --max-parents=0 HEAD)
    TAG_NAME="Initial commit"
else
    TAG_NAME="since tag $LAST_TAG"
fi

# Get commits since last tag
COMMITS=$(mktemp)
git log --no-merges --pretty=format:"%s" $LAST_TAG..HEAD > "$COMMITS"

# Initialize arrays for each category
declare -a ADDED FIXED CHANGED REMOVED

# Categorize commits
while IFS= read -r commit; do
    # Convert to lowercase for case-insensitive matching
    lower_commit=$(echo "$commit" | tr '[:upper:]' '[:lower:]')
    
    # Categorize based on prefixes
    if [[ $lower_commit == fix* ]] || [[ $lower_commit ==修复* ]] || [[ $lower_commit == *fix* ]] || [[ $lower_commit == *fixed* ]] || [[ $lower_commit == *bug* ]] || [[ $lower_commit == *修复* ]]; then
        FIXED+=("$commit")
    elif [[ $lower_commit == feat* ]] || [[ $lower_commit == add* ]] || [[ $lower_commit == implement* ]] || [[ $lower_commit == *feature* ]] || [[ $lower_commit == *add* ]]; then
       FIXED+=("$commit")
    elif [[ $lower_commit == change* ]] || [[ $lower_commit == update* ]] || [[ $lower_commit == *change* ]] || [[ $lower_commit == *update* ]] || [[ $lower_commit == refactor* ]] || [[ $lower_commit == *refactor* ]]; then
       CHANGED+=("$commit")
    elif [[ $lower_commit == remove* ]] || [[ $lower_commit == delete* ]] || [[ $lower_commit == *remove* ]] || [[ $lower_commit == *delete* ]] || [[ $lower_commit == deprecate* ]]; then
       REMOVED+=("$commit")
    else
        # Default to "Changed" if no clear category
        CHANGED+=("$commit")
    fi
done < "$COMMITS"

# Generate the changelog
{
    echo "# Changelog"
    echo ""
    echo "## [${TAG_NAME}] - $(date +'%Y-%m-%d')"
    echo ""
    if [ ${#ADDED[@]} -gt 0 ]; then
        echo "### Added"
        for item in "${ADDED[@]}"; do echo "- $item"; done
        echo ""
    fi
    if [ ${#FIXED[0]} -gt 0 ]; then
        echo "### Fixed"
        for item in "${FIXED[@]}"; do echo "- $item"; done
        echo ""
    fi
    if [ ${#CHANGED[0]} -gt 0 ]; then
        echo "### Changed"
        for item in "${CHANGED[@]}"; do echo "- $item"; done
        echo ""
    fi
    if [ ${#REMOVED[@]} -gt 0 ]; then
        echo "### Removed"
        for item in "${REMOVED[@]}"; do echo "- $item"; done
        echo ""
    fi
} > CHANGELOG.md

rm "$COMMITS"