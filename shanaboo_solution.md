 ```diff
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,152 @@
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
+# Get the last git tag
+get_last_tag() {
+    git describe --tags --abbrev=0 2>/dev/null || echo ""
+}
+
+# Get commits since a given tag (or all commits if no tag)
+get_commits_since_tag() {
+    local tag="$1"
+    if [ -n "$tag" ]; then
+        git log "${tag}..HEAD" --pretty=format:"%s" 2>/dev/null || echo ""
+    else
+        git log --pretty=format:"%s" 2>/dev/null || echo ""
+    fi
+}
+
+# Categorize a commit message
+categorize_commit() {
+    local msg="$1"
+    local lower_msg
+    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
+    
+    # Check for conventional commit prefixes first
+    if echo "$lower_msg" | grep -qE '^(feat|add|introduce|implement|create|new)'; then
+        echo "added"
+    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|patch|resolve|correct)'; then
+        echo "fixed"
+    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|revert|deprecate)'; then
+        echo "removed"
+    elif echo "$lower_msg" | grep -qE '^(update|modify|change|refactor|improve|enhance|upgrade|rework)'; then
+        echo "changed"
+    # Check for keywords patterns in the message
+    elif echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|create|new)\b'; then
+        echo "added"
+    elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|bug|resolve|correct|patch)\b'; then
+        echo "fixed"
+    elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|drop|revert|deprecate)\b'; then
+        echo "removed"
+    elif echo "$lower_msg" | grep -qE '\b(update|updated|updating|modify|modified|change|changed|refactor|improve|improved|enhance|enhanced|upgrade|upgraded|rework)\b'; then
+        echo "changed"
+    else
+        echo "changed"  # Default category
+    fi
+}
+
+# Generate the changelog
+generate_changelog() {
+    local last_tag
+    last_tag=$(get_last_tag)
+    
+    local commits
+    commits=$(get_commits_since_tag "$last_tag")
+    
+    if [ -z "$commits" ]; then
+        echo -e "${YELLOW}No commits found since last tag.${NC}"
+        if [ -n "$last_tag" ]; then
+            echo "Last tag: $last_tag"
+        else
+            echo "No tags found in repository."
+        fi
+        exit 0
+    fi
+    
+    # Initialize category arrays
+    local added=()
+    local fixed=()
+    local changed=()
+    local removed=()
+    
+    # Categorize each commit
+    while IFS= read -r commit; do
+        [ -z "$commit" ] && continue
+        
+        local category
+        category=$(categorize_commit "$commit")
+        
+        case "$category" in
+            added) added+=("$commit") ;;
+            fixed) fixed+=("$commit") ;;
+            removed) removed+=("$commit") ;;
+            changed) changed+=("$commit") ;;
+        esac
+    done <<< "$commits"
+    
+    # Generate CHANGELOG.md
+    {
+        echo "# Changelog"
+        echo ""
+        
+        local version_date
+        version_date=$(date +%Y-%m-%d)
+        
+        if [ -n "$last_tag" ]; then
+            echo "## [Unreleased] - $version_date"
+        else
+            echo "## [Unreleased] - $version_date"
+        fi
+        echo ""
+        
+        # Added
+        if [ ${#added[@]} -gt 0 ]; then
+            echo "### Added"
+            printf -- "- %s\n" "${added[@]}"
+            echo ""
+        fi
+        
+        # Changed
+        if [ ${#changed[@]} -gt 0 ]; then
+            echo "### Changed"
+            printf -- "- %s\n" "${changed[@]}"
+            echo ""
+        fi
+        
+        # Fixed
+        if [ ${#fixed[@]} -gt 0 ]; then
+            echo "### Fixed"
+            printf -- "- %s\n" "${fixed[@]}"
+            echo ""
+        fi
+        
+        # Removed
+        if [ ${#removed[@]} -gt 0 ]; then
+            echo "### Removed"
+            printf -- "- %s\n" "${removed[@]}"
+            echo ""
+        fi
+        
+    } > CHANGELOG.md
+    
+    echo -e "${GREEN}✓ CHANGELOG.md generated successfully!${NC}"
+    if [ -n "$last_tag" ]; then
+        echo "  Commits since tag: $last_tag"
+    fi
+    echo "  Added:   ${#added[@]}"
+    echo "  Changed: ${#changed[@]}"
+    echo "  Fixed:   ${#fixed[@]}"
+    echo "  Removed: ${#removed[@]}"
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
+    generate_changelog
+}
+
+main "$@"
+
+--- /dev/null
+++	SKILL.md
@@ -0,0 +1,49 @@
+# Generate Changelog Skill
+
+A Claude Code