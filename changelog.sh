#!/usr/bin/env bash

# changelog.sh - Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the last git tag
get_last_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since a given tag (or all commits if no tag)
get_commits_since() {
    local tag="$1"
    if [ -z "$tag" ]; then
        git log --pretty=format:"%s" --no-merges
    else
        git log "${tag}..HEAD" --pretty=format:"%s" --no-merges
    fi
}

# Categorize a commit message
categorize_commit() {
    local msg="$1"
    local lower_msg
    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
    
    # Check for conventional commit prefixes first
    if [[ "$lower_msg" =~ ^feat(\(.+\))?: ]]; then
        echo "added"
    elif [[ "$lower_msg" =~ ^fix(\(.+\))?: ]]; then
        echo "fixed"
    elif [[ "$lower_msg" =~ ^(chore|refactor|perf|style|docs|test)(\(.+\))?: ]]; then
        echo "changed"
    elif [[ "$lower_msg" =~ ^(remove|delete|drop|revert)(\(.+\))?: ]]; then
        echo "removed"
    else
        # Fallback: keyword-based categorization
        if [[ "$lower_msg" =~ (add|new|introduce|create|implement|support) ]]; then
            echo "added"
        elif [[ "$lower_msg" =~ (fix|bug|resolve|patch|correct|repair) ]]; then
            echo "fixed"
        elif [[ "$lower_msg" =~ (remove|delete|drop|revert|clean) ]]; then
            echo "removed"
        else
            echo "changed"
        fi
    fi
}

# Generate the CHANGELOG.md
generate_changelog() {
    local last_tag
    last_tag=$(get_last_tag)
    local version_date
    version_date=$(date +%Y-%m-%d)
    
    # Collect commits by category
    local added=()
    local fixed=()
    local changed=()
    local removed=()
    
    while IFS= read -r commit; do
        [ -z "$commit" ] && continue
        
        local category
        category=$(categorize_commit "$commit")
        
        # Strip conventional commit prefix for cleaner output
        local clean_commit
        clean_commit=$(echo "$commit" | sed -E 's/^(feat|fix|chore|refactor|perf|style|docs|test|remove|delete|drop|revert)(\([^)]+\))?: ?//')
        
        case "$category" in
            added)   added+=("- $clean_commit") ;;
            fixed)   fixed+=("- $clean_commit") ;;
            changed) changed+=("- $clean_commit") ;;
            removed) removed+=("- $clean_commit") ;;
        esac
    done < <(get_commits_since "$last_tag")
    
    # Determine version header
    local version_header
    if [ -n "$last_tag" ]; then
        version_header="## [Unreleased] - ${version_date}"
    else
        version_header="## [Unreleased] - ${version_date}"
    fi
    
    # Build output
    {
        echo "# Changelog"
        echo ""
        echo "All notable changes to this project will be documented in this file."
        echo ""
        echo "$version_header"
        echo ""
        
        if [ ${#added[@]} -gt 0 ]; then
            echo "### Added"
            printf '%s\n' "${added[@]}"
            echo ""
        fi
        
        if [ ${#fixed[@]} -gt 0 ]; then
            echo "### Fixed"
            printf '%s\n' "${fixed[@]}"
            echo ""
        fi
        
+        if [ ${#changed[@]} -gt 0 ]; then
            echo "### Changed"
            printf '%s\n' "${changed[@]}"
            echo ""
        fi
+        
+        if [ ${#removed[@]} -gt 0 ]; then
+            echo "### Removed"
+            printf '%s\n' "${removed[@]}"
+            echo ""
+        fi
+    } > CHANGELOG.md
+    
+    echo -e "${GREEN}✓ CHANGELOG.md generated successfully${NC}"
+    if [ -n "$last_tag" ]; then
+        echo -e "${YELLOW}  Commits since tag: $last_tag${NC}"
+    else
+        echo -e "${YELLOW}  No previous tags found — using all commits${NC}"
+    fi
+}
+
+# Main execution
+main() {
+    # Check if we're in a git repository
+    if ! git rev-parse --git-dir > /dev/null 2>&1; then
+        echo -e "${RED}Error: Not a git repository${NC}" >&2
+        exit 1
+    fi
+    
+    # Check if there are any commits
+    if ! git log --oneline -1 > /dev/null 2>&1; then
+        echo -e "${RED}Error: No commits found in repository${NC}" >&2
+        exit 1
+    fi
+    
+    generate_changelog
+}
+
+main "$@"

--- /dev/null
# Generate Changelog Skill

## Description

Automatically generate a structured `CHANGELOG.md` from a project's git history.

## Usage

