#!/bin/bash

# Get the latest tag
LATEST_TAG=$(git describe --tags $(git rev-list --tags --max-count=1) 2>/dev/null)

# If no tag is found, use the initial commit as the starting point
if [ -z "$LATEST_TAG" ]; then
    LATEST_TAG=$(git rev-list --max-parents=0 HEAD)
    echo "No tags found. Using initial commit."
fi

# Get commits since the latest tag
COMMITS=$(git log $LATEST_TAG..HEAD --pretty=format:"%s" --reverse)

# If no commits since last tag, exit
if [ -z "$COMMITS" ]; then
    echo "No commits since last tag. No changelog to generate."
    exit 0
fi

# Initialize changelog content
CHANGELOG_CONTENT=""

# Categories
ADDED=()
FIXED=()
CHANGED=()
REMOVED=()
OTHER=()

# Process commits
while IFS= read -r COMMIT; do
    if [[ $COMMIT == *"add:"* ]] || [[ $COMMIT == *"feat:"* ]] || [[ $COMMIT == *"new:"* ]]; then
        ADDED+=("$COMMIT")
    elif [[ $COMMIT == *"fix:"* ]]; then
        FIXED+=("$COMMIT")
    elif [[ $COMMIT == *"change:"* ]] || [[ $COMCMIT == *"refactor:"* ]] || [[ $COMMIT == *"update:"* ]]; then
        CHANGED+=("$COMMIT")
    elif [[ $COMMIT == *"remove:"* ]] || [[ $COMMIT == *"delete:"* ]] || [[ $COMMIT == *"rm:"* ]]; then
        REMOVED+=("$COMMIT")
    else
        OTHER+=("$COMMIT")
    fi
done <<< "$COMMITS"

# Function to add section to changelog
add_section() {
    local section_name=$1
    shift
    local commits=("$@")
    
    if [ ${#commits[@]} -gt 0 ]; then
        CHANGELOG_CONTENT+="## $section_name\n"
        for commit in "${commits[@]}"; do
            # Remove the prefix (e.g. "add: ", "fix: ") from the commit message
            clean_message=$(echo "$commit" | sed -E 's/^(add:|feat:|new:|fix:|change:|refactor:|update:|remove:|delete:|rm:)//' | xargs)
            if [ -n "$clean_message" ]; then
                CHANGELOG_CONTENT+="* $clean_message\n"
            fi
        done
        CHANGELOG_CONTENT+="\n"
    fi
}

# Build changelog content
CHANGELOG_CONTENT="# Changelog\n\n"
CHANGELOG_CONTENT+="$(date +'%Y-%m-%d')\n\n"

add_section "Added" "${ADDED[@]}"
add_section "Fixed" "${FIXED[@]}"
add_section "Changed" "${CHANGED[@]}"
add_section "Removed" "${REMOVED[@]}"

if [ ${#OTHER[@]} -gt 0 ]; then
    CHANGELOG_CONTENT+="## Other\n"
    for commit in "${OTHER[@]}"; do
        CHANGELOG_CONTENT+="* $commit\n"
    done
fi

# Write to file
echo -e "$CHANGELOG_CONTENT" > CHANGELOG.md

echo "Changelog generated in CHANGELOG.md"