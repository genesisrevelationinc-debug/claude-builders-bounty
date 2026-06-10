#!/bin/bash

# changelog.sh - Generate a structured CHANGELOG.md from git history

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "  -h, --help     Display this help message"
    echo "  No arguments needed to generate changelog"
}

# Get the last tag
get_last_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0"
}

# Categorize commit based on keywords
categorize_commit() {
    local message="$1"
    if [[ $message == *"add"* ]] || [[ $message == *"feat"* ]] || [[ $message == *"new"* ]]; then
        echo "Added"
    elif [[ $message == *"fix"* ]] || [[ $message == *"Fix"* ]] || [[ $message == *"fix" || $message == *"fixed"* ]]; then
        echo "Fixed"
    elif [[ $message == *"change"* ]] || [[ $message == *"update"* ]] || [[ $message == *"refactor"* ]]; then
        echo "Changed"
    elif [[ $message == *"remove"* ]] || [[ $message == *"delete"* ]] || [[ $message == *"rm"* ]]; then
        echo "Removed"
    else
        echo "Changed"  # Default category
    fi
}

# Main function to generate changelog
generate_changelog() {
    local last_tag=$(get_last_tag)
    echo "Generating changelog from commits since $last_tag..."
    
    # Create a temporary file to store the changelog
    temp_file=$(mktemp)
    
    # Write header
    echo "# Changelog" > "$temp_file"
    echo "" >> "$temp_file"
    
    # Get commits since last tag and categorize them
    # Initialize category arrays
    added_commits=()
    fixed_commits=()
    changed_commits=()
    removed_commits=()
    
    # Process each commit
    while IFS= read -r commit; do
        category=$(categorize_commit "$commit")
        case $category in
            "Added") added_commits+=("$commit") ;;
            "Fixed") fixed_commits+=("$commit") ;;
            "Changed") changed_commits+=("$commit") ;;
            "Removed") removed_commits+=("$commit") ;;
        esac
    done < <(git log --oneline "$last_tag"..HEAD --no-merges --pretty=format:"%s")
    
    # Write categorized commits to changelog
    if [ ${#added_commits[@]} -gt 0 ]; then
        echo "## Added" >> "$temp_file"
        for commit in "${added_commits[@]}"; do
            echo "- $commit" >> "$temp_file"
        done
        echo "" >> "$tempfile"
    fi
    
    if [ ${#fixed_commits[@]} -gt 0 ]; then
        echo "## Fixed" >> "$temp_file"
        for commit in "${fixed_commits[@]}"; do
            echo "- $commit" >> "$temp_file"
        done
        echo "" >> "$temp_file"
    fi
    
    if [ ${#changed_commits[@]} -gt 0 ]; then
        echo "## Changed" >> "$temp_file"
        for commit in "${changed_commits[@]}"; do
            echo "- $commit" >> "$temp_file"
        done
        echo "" >> "$temp_file"
    fi
    
    if [ ${#removed_commits[@]} -gt 0 ]; then
        echo "## Removed" >> "$temp_file"
        for commit in "${removed_commits[@]}"; do
            echo "- $commit" >> "$temp_file"
        done
        echo "" >> "$temp_file"
    fi
    
    # Output to CHANGELOG.md
    mv "$temp_file" "CHANGELOG.md"
    echo "CHANGELOG.md generated successfully!"
}

# Run the script
generate_changelog