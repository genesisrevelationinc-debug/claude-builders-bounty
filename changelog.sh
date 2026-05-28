#!/bin/bash

# Function to display script usage
usage() {
    echo "Usage: $0 [START_TAG] [END_TAG]"
    echo "Generate a changelog from git history between two tags"
    echo ""
    echo "Arguments:"
    echo "  START_TAG    The starting tag (optional, defaults to latest tag)"
    echo "  END_TAG     The ending tag (optional, defaults to HEAD)"
    echo ""
    echo "If no arguments are provided, the script will generate a changelog from the last tag to the current HEAD."
    exit 1
}

# Set the start and end tags
# If no tags are provided, use the last tag as start and HEAD as end
if [ -z "$START_TAG" ] && [ -z "$END_TAG" ]; then
    START_TAG=$(git describe --tags --abbrev=0 2>/dev/null)
    if [ -z "$START_TAG" ]; then
        echo "No tags found in the repository"
        exit 1
    fi
    END_TAG="HEAD"
else
    START_TAG=$1
    END_TAG=${2:-HEAD}
fi

# Function to categorize commits
categorize_commits() {
    local start_tag="$1"
    local end_tag="$2"
    
    # Get commits between the specified tags
    if [ "$start_tag" = "$end_tag" ] && [ "$end_tag" = "HEAD" ]; then
        commits=$(git log --oneline "$start_tag".."$end_tag" --no-merges)
    else
        # If there is only one tag, use it as a reference for git log
        if [ "$start_tag" = "$(git describe --tags --abbrev=0 2>/dev/null)" ]; then
            commits=$(git log --on-line --no-merges "$(git describe --tags --abbrev=0)"..HEAD)
        else
            # If there are no tags, get all commits
            if [ -z "$(git tag -l)" ]; then
                commits=$(git log --oneline --no-merges)
            else
                # If there are tags, get the commits from the last tag
                last_tag=$(git describe --tags --abbrev=0)
                commits=$(git log --oneline "$last_tag"..HEAD --no-merges)
            fi
        fi
    fi
    
    # Categorize the commits
    echo "## Unreleased" > CHANGELOG.md
    echo "" >> CHANGELOG.md
    
    # Generate the changelog
    echo "$commits" | while read -r commit; do
        if [[ $commit == *"add"* ]] || [[ $commit == *"new"* ]] || [[ $commit == *"Add"* ]] || [[ $commit == *"ADD"* ]]; then
            echo "### Added" >> CHANGELOG.md
            echo "- $commit" >> CHANGELOG.md
        elif [[ $commit == *"fix"* ]] || [[ $commit == *"Fix"* ]] || [[ $commit == *"FIX"* ]] || [[ $commit == *"bug"* ]] || [[ $commit == *"BUG"* ]]; then
            echo "### Fixed" >> CHANGELOG.md
            echo "- $commit" >> CHANGELOG.md
        else
            echo "### Other" >> CHANGELOG.md
            echo "- $commit" >> CHANGELOG.md
        fi
    done
    
    echo "" >> CHANGELOG.md
}

# Main
main() {
    # Get the start and end tags from the arguments
    START_TAG=$1
    END_TAG=${2:-HEAD}
    
    # Call the function to categorize the commits
    categorize_commits "$START_TAG" "$END_TAG"
    
    echo "Changelog generated!"
}

main "$@"