#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

REPO_URL=$(git remote get-url origin 2>/dev/null || echo "")
if [[ -z "$REPO_URL" ]]; then
    echo "Error: Not a git repository or no remote 'origin' set." >&2
    exit 1
fi

# Determine the last tag; if none, use the first commit
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || git rev-list --max-parents=0 HEAD 2>/dev/null || echo "")
if [[ -z "$LAST_TAG" ]]; then
    echo "Error: No tags and no commits found." >&2
    exit 1
fi

# Get commits since last tag (or all commits if no tag)
if git describe --tags --abbrev=0 >/dev/null 2>&1; then
    COMMITS=$(git log "$LAST_TAG"..HEAD --pretty=format:"%s" 2>/dev/null || true)
else
    COMMITS=$(git log --pretty=format:"%s" 2>/dev/null || true)
fi

if [[ -z "$COMMITS" ]]; then
    echo "No new commits since $LAST_TAG." >&2
    exit 0
fi

# Categorize commits
ADDED=()
FIXED=()
CHANGED=()
REMOVED=()
OTHER=()

while IFS= read -r line; do
    # Skip empty lines
    [[ -z "$line" ]] && continue

    # Categorize based on conventional commit prefixes or keywords
    lower_line=$(echo "$line" | tr '[:upper:]' '[:lower:]')

    if [[ "$lower_line" =~ ^(feat|add|create|introduce|implement|new) ]] || \
       [[ "$lower_lineEncoded" =~ (add|adds|added|adding|create|creates|created|introduce|introduces|introduced|implement|implements|implemented) ]]; then
        ADDED+=("$line")
    elif [[ "$lower_line" =~ ^(fix|bugfix|hotfix|patch|resolve) ]] || \
         [[ "$lower_line" =~ (fix|fixes|fixed|fixing|bug|bugfix|patch|resolve|resolves|resolved) ]]; then
        FIXED+=("$line")
    elif [[ "$lower_line" =~ ^(remove|delete|drop|deprecate|revert) ]] || \
         [[ "$lower_line" =~ (remove|removes|removed|removing|delete|deletes|deleted|deleting|drop|drops|dropped|deprecate|deprecates|deprecated|revert|reverts|reverted) ]]; then
        REMOVED+=("$line")
    elif [[ "$lower_line" =~ ^(change|update|modify|refactor|improve|enhance|upgrade|rework|optimize) ]] || \
         [[ "$lower_line" =~ (update|updates|updated|updating|modify|modifies|modified|modifying|refactor|refactored|refactoring|improve|improves|improved|improving|enhance|enhances|enhanced|enhancing|upgrade|upgrades|upgraded|upgrading|rework|reworked|reworing|optimize|optimizes|optimized|optimizing) ]]; then
        CHANGED+=("$line")
    else
        OTHER+=("$line")
    fi
done <<< "$COMMITS"

# Fallback: if all went to OTHER, try keyword matching in message body
if [[ ${#ADDED[@]} -eq 0 && ${#FIXED[@]} -eq 0 && ${#CHANGED[@]} -eq 0 && ${#REMOVED[@]} -eq 0 && ${#OTHER[@]} -gt 0 ]]; then
    for line in "${OTHER[@]}"; do
        lower_line=$(echo "$line" | tr '[:upper:]' '[:lower:]')
        if [[ "$lower_line" =~ fix|bug|patch|resolve ]]; then
            FIXED+=("$line")
        elif [[ "$lower_line" =~ add|create|introduce|implement|new ]]; then
            ADDED+=("$line")
        elif [[ "$lower_line" =~ remove|delete|drop|deprecate ]]; then
            REMOVED+=("$line")
        elif [[ "$lower_line" =~ update|modify|refactor|improve|enhance|upgrade|change ]]; then
            CHANGED+=("$line")
        else
            # Keep in OTHER if still no match
            :
        fi
    done
    # Clear OTHER since we re-categorized
    OTHER=()
fi

# Generate CHANGELOG.md
DATE=$(date +%Y-%m-%d)
NEXT_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "latest")
HEAD_SHA=$(git rev-parse --short HEAD)

cat > CHANGELOG.md <<EOF
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - $DATE

EOF

output_section() {
    local title="$1"
    shift
    local -a items=("$@")
    if [[ ${#items[@]} -gt 0 ]]; then
        echo "### $title" >> CHANGELOG.md
        echo "" >> CHANGELOG.md
        for item in "${items[@]}"; do
            # Escape backticks for markdown
            safe_item=$(echo "$item" | sed 's/`/\\`/g')
            echo "- $safe_item" >> CHANGELOG.md
        done
        echo "" >> CHANGELOG.md
    fi
}

output_section "Added" "${ADDED[@]}"
output_section "Changed" "${CHANGED[@]}"
output_section "Fixed" "${FIXED[@]}"
output_section "Removed" "${REMOVED[@]}"
output_section "Other" "${OTHER[@]}"

echo "✅ CHANGELOG.md generated successfully!"
echo "   Based on commits since: $LAST_TAG"
echo "   Output: CHANGELOG.md"