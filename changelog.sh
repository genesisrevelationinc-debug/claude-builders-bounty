#!/bin/bash

# changelog.sh - Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

# Get the latest git tag or default to initial commit
latest_tag=$(git describe --tags --abbrev=0 2>/dev/null) || latest_tag=""

# Determine the commit range
if [ -z "$latest_tag" ]; then
    commit_range=""
    echo "No previous tags found. Generating changelog for all commits."
else
    commit_range="$latest_tag..HEAD"
    echo "Generating changelog from commits since tag: $latest_tag"
fi

# Create temporary file for processing
temp_file=$(mktemp)

# Get commits in the specified range
if [ -z "$commit_range" ]; then
    git log --pretty=format:"%s" > "$temp_file"
else
    git log "$commit_range" --pretty=format:"%s" > "$temp_file"
fi

# Initialize arrays for different categories
declare -a added_arr=()
declare -a fixed_arr=()
declare -a changed_arr=()
declare -a removed_arr=()

# Categorize commits based on their prefixes
while IFS= read -r line; do
    case "$line" in
        Add:*|add:*|Added:*|added:*) 
            added_arr+=("${line#*: }")
            ;;
        Fix:*|fix:*|Fixed:*|fixed:*) 
            fixed_arr+=("${line#*: }")
            ;;
        Change:*|change:*|Changed:*|changed:*) 
            changed_arr+=("${line#*: }")
            ;;
        Remove:*|remove:*|Removed:*|removed:*) 
            removed_arr+=("${line#*: }")
            ;;
        *)
            # Default to "Changed" if no prefix
            changed_arr+=("$line")
            ;;
    esac
done < "$temp_file"

# Write to CHANGELOG.md
echo "# Changelog" > CHANGELOG.md
echo "" >> CHANGELOG.md
[ ${#added_arr[@]} -gt 0 ] && { echo "## Added" >> CHANGELOG.md; printf '%s\n' "${added_arr[@]/#/ - }" >> CHANGELOG.md; echo "" >> CHANGELOG.md; }
[ ${#fixed_arr[@]} -gt 0 ] && { echo "## Fixed" >> CHANGELOG.md; printf '%s\n' "${fixed_arr[@]/#/ - }" >> CHANGELOG.md; echo "" >> CHANGELOG.md; }
[ ${#changed_arr[@]} -gt 0 ] && { echo "## Changed" >> CHANGELOG.md; printf '%s\n' "${changed_arr[@]/#/ - }" >> CHANGELOG.md; echo "" >> CHANGELOG.md; }
[ ${#removed_arr[@]} -gt 0 ] && { echo "## Removed" >> CHANGELOG.md; printf '%s\n' "${removed_arr[@]/#/ - }" >> CHANGELOG.md; echo "" >> CHANGELOG.md; }

# Cleanup
rm "$temp_file"

echo "CHANGELOG.md has been generated successfully."