 ```diff
--- /dev/null
+++ b/generate-changelog.sh
@@ -0,0 +1,148 @@
+#!/usr/bin/env bash
+
+# generate-changelog.sh
+# Automatically generates a structured CHANGELOG.md from git history
+# Fetches commits since the last git tag and auto-categorizes them
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
+CHANGELOG_FILE="CHANGELOG.md"
+DATE=$(date +%Y-%m-%d)
+
+# Get the latest tag
+get_latest_tag() {
+    git describe --tags --abbrev=0 2>/dev/null || echo ""
+}
+
+# Get commits since the last tag (or all commits if no tag)
+get_commits_since_tag() {
+    local tag="$1"
+    if [ -n "$tag" ]; then
+        git log "$tag"..HEAD --pretty=format:"%s" --no-merges
+    else
+        git log --pretty=format:"%s" --no-merges
+    fi
+}
+
+# Categorize a single commit message
+categorize_commit() {
+    local msg="$1"
+    local lower_msg
+    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
+    
+    # Check for conventional commit prefixes first
+    if [[ "$lower_msg" =~ ^feat(\(.+\))?: ]]; then
+        echo "added"
+        return
+    elif [[ "$lower_msg" =~ ^fix(\(.+\))?: ]]; then
+        echo "fixed"
+        return
+    elif [[ "$lower_msg" =~ ^(chore|refactor|perf|style|docs|test|build|ci|revert)(\(.+\))?: ]]; then
+        echo "changed"
+        return
+    fi
+    
+    # Fallback: keyword-based categorization
+    if [[ "$lower_msg" =~ ^(add|create|implement|introduce|new|support|enable|feat) ]]; then
+        echo "added"
+    elif [[ "$lower_msg" =~ ^(fix|bug|repair|resolve|patch|correct|hotfix) ]]; then
+        echo "fixed"
+    elif [[ "$lower_msg" =~ ^(remove|delete|drop|eliminate|deprecate|clean) ]]; then
+        echo "removed"
+    elif [[ "$lower_msg" =~ ^(update|change|modify|refactor|improve|enhance|upgrade|rework|optimize) ]]; then
+        echo "changed"
+    else
+        # Default to changed if no match
+        echo "changed"
+    fi
+}
+
+# Clean commit message (remove conventional commit prefix)
+clean_message() {
+    local msg="$1"
+    # Remove conventional commit prefix like "feat:", "fix(scope):", etc.
+    echo "$msg" | sed -E 's/^[a-zA-Z]+(\([^)]+\))?:[[:space:]]*//'
+}
+
+# Generate the changelog
+generate_changelog() {
+    local tag
+    tag=$(get_latest_tag)
+    
+    echo -e "${GREEN}Generating changelog...${NC}"
+    
+    if [ -n "$tag" ]; then
+        echo -e "${YELLOW}Latest tag: $tag${NC}"
+    else
+        echo -e "${YELLOW}No tags found. Using all commits.${NC}"
+    fi
+    
+    # Read commits into arrays by category
+    local added=()
+    local fixed=()
+    local changed=()
+    local removed=()
+    
+    while IFS= read -r commit; do
+        [ -z "$commit" ] && continue
+        
+        local category
+        category=$(categorize_commit "$commit")
+        local clean_msg
+        clean_msg=$(clean_message "$commit")
+        
+        case "$category" in
+            added)   added+=("- $clean_msg") ;;
+            fixed)   fixed+=("- $clean_msg") ;;
+            changed) changed+=("- $clean_msg") ;;
+            removed) removed+=("- $clean_msg") ;;
+        esac
+    done < <(get_commits_since_tag "$tag")
+    
+    # Determine version header
+    local version_header
+    if [ -n "$tag" ]; then
+        version_header="## [Unreleased] - $DATE"
+    else
+        version_header="## [Unreleased] - $DATE"
+    fi
+    
+    # Build changelog content
+    {
+        echo "# Changelog"
+        echo ""
+        echo "$version_header"
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
+        # Append existing changelog if it exists (skip the header)
+        if [ -f "$CHANGELOG_FILE" ]; then
+            tail -n +3 "$CHANGELOG_FILE" 2>/dev/null || true
+        fi
+    } > "$CHANGELOG_FILE.tmp"
+    
+    mv "$CHANGELOG_FILE.tmp" "$CHANGELOG_FILE"
+    
+    echo -e "${GREEN}✓ CHANGELOG.md generated successfully!${NC}"
+    echo -e "${YELLOW}Location: $(pwd)/$CHANGELOG_FILE${NC}"
+}
+
+# Main execution
+main() {
+    # Check if we're in a git repository
+    if ! git rev-parse --git-dir > /dev/null 2>&1; then
+        echo -e "${RED}Error: Not a git repository.${NC}" >&2
+        exit 1
+    fi
+    
+    # Check if there are any commits
+    if ! git log --oneline -1 > /dev/null 2>&1; then
+        echo -e "${RED}Error: No commits found in this repository.${NC}" >&2