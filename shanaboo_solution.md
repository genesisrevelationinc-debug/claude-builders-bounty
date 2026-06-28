 ```diff
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,148 @@
+#!/usr/bin/env bash
+
+# changelog.sh - Generate a structured CHANGELOG.md from git history
+# Usage: bash changelog.sh
+
+set -euo pipefail
+
+# Colors for output
+RED='\033[0;31m'
+GREEN='\033[0;32m'
+YELLOW='\033[1;33m'
+NC='\033[0m' # No Color
+
+# Configuration
+OUTPUT_FILE="CHANGELOG.md"
+REPO_URL=""
+
+# Get the remote URL for generating links
+get_repo_url() {
+    local remote_url
+    remote_url=$(git remote get-url origin 2>/dev/null || echo "")
+    if [[ "$remote_url" == git@github.com:* ]]; then
+        REPO_URL=$(echo "$remote_url" | sed 's|git@github.com:|https://github.com/|' | sed 's/\.git$//')
+    elif [[ "$remote_url" == https://github.com/* ]]; then
+        REPO_URL=$(echo "$remote_url" | sed 's/\.git$//')
+    fi
+}
+
+# Get the latest git tag
+get_latest_tag() {
+    git describe --tags --abbrev=0 2>/dev/null || echo ""
+}
+
+# Get commits since the last tag (or all commits if no tag)
+get_commits_since_tag() {
+    local tag="$1"
+    if [ -n "$tag" ]; then
+        git log "$tag..HEAD" --pretty=format:"%H|%s|%b" --no-merges
+    else
+        git log --pretty=format:"%H|%s|%b" --no-merges
+    fi
+}
+
+# Categorize a commit based on its message
+categorize_commit() {
+    local message="$1"
+    local lower_msg
+    lower_msg=$(echo "$message" | tr '[:upper:]' '[:lower:]')
+    
+    # Check for conventional commit prefixes firstnitialize
+    if [[ "$lower_msg" =~ ^feat(\(.*\))?: ]]; then
+        echo "added"
+    elif [[ "$lower_msg" =~ ^fix(\(.*\))?: ]]; then
+        echo "fixed"
+    elif [[ "$lower_msg" =~ ^(chore|refactor|perf|style|docs|test)(\()? ]]; then
+        echo "changed"
+    elif [[ "$lower_msg" =~ ^(remove|delete|drop|revert)(\()? ]]; then
+        echo "removed"
+    # Fallback to keyword matching
+    elif echo "$lower_msg" | grep -qE '\b(add|create|implement|introduce|new)\b'; then
+        echo "added"
+    elif echo "$lower_msg" | grep -qE '\b(fix|bug|resolve|patch|correct)\b'; then
+        echo "fixed"
+    elif echo "$lower_msg" | grep -qE '\b(remove|delete|drop|revert|deprecate)\b'; then
+        echo "removed"
+    else
+        echo "changed"
+    fi
+}
+
+# Generate the changelog
+generate_changelog() {
+    local latest_tag
+    latest_tag=$(get_latest_tag)
+    
+    echo -e "${GREEN}Generating CHANGELOG...${NC}"
+    
+    if [ -n "$latest_tag" ]; then
+        echo -e "${YELLOW}Latest tag: $latest_tag${NC}"
+    else
+        echo -e "${YELLOW}No tags found. Using all commits.${NC}"
+    fi
+    
+    get_repo_url
+    
+    local commits
+    commits=$(get_commits_since_tag "$latest_tag")
+    
+    if [ -z "$commits" ]; then
+        echo -e "${RED}No commits found since last tag.${NC}"
+        exit 0
+    fi
+    
+    # Initialize arrays for categories
+    local added=() fixed=() changed=() removed=()
+    
+    # Process each commit
+    while IFS='|' read -r hash subject body; do
+        [ -z "$hash" ] && continue
+        
+        local category
+        category=$(categorize_commit "$subject")
+        
+        local commit_link=""
+        if [ -n "$REPO_URL" ]; then
+            commit_link=" ([${hash:0:7}](${REPO_URL}/commit/${hash}))"
+        else
+            commit_link=" (${hash:0:7})"
+        fi
+        
+        local entry="- ${subject}${commit_link}"
+        
+        case "$category" in
+            added)   added+=("$entry") ;;
+            fixed)   fixed+=("$entry") ;;
+            changed) changed+=("$entry") ;;
+            removed) removed+=("$entry") ;;
+        esac
+    done <<< "$commits"
+    
+    # Generate the changelog file
+    {
+        echo "# Changelog"
+        echo ""
+        echo "All notable changes to this project will be documented in this file."
+        echo ""
+        echo "The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),"
+        echo "and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)."
+        echo ""
+        
+        local version_date
+        version_date=$(date +%Y-%m-%d)
+        local version_header="[Unreleased]"
+        
+        if [ -n "$latest_tag" ]; then
+            version_header="[${latest_tag}] - ${version_date}"
+        fi
+        
+        echo "## ${version_header}"
+        echo ""
+        
+        if [ ${#added[@]} -gt 0 ]; then
+            echo "### Added"
+            printf '%s\n' "${added[@]}"
+            echo ""
+        fi
+        
+        if [ ${#fixed[@]} -gt 0 ]; then
+            echo "### Fixed"
+            printf '%s\n' "${fixed[@]}"
+            echo ""
+        fi
+        
+        if [ ${#changed[@]} -gt 0 ]; then
+            echo "### Changed"
+            printf '%s\n' "${changed[@]}"
+            echo ""
+        fi
+        
+        if [ ${#removed[@]} -gt 0 ]; then
+            echo "### Removed"
+            printf '%s\n' "${removed[@]}"
+            echo ""
+        fi
+        
+        echo "---"
+        echo ""
+        echo "*Generated automatically by [changelog.sh](changelog.sh)*"
+