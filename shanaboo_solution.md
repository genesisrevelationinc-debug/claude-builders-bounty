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
+OUTPUT_TO_STDOUT=false
+
+# Parse arguments
+while [[ $# -gt 0 ]]; do
+    case $1 in
+        --stdout)
+            OUTPUT_TO_STDOUT=true
+            shift
+            ;;
+        --help|-h)
+            echo "Usage: $0 [--stdout]"
+            echo "  --stdout    Output to stdout instead of writing to CHANGELOG.md"
+            exit 0
+            ;;
+        *)
+            echo "Unknown option: $1"
+            exit 1
+            ;;
+    esac
+done
+
+# Check if we're in a git repository
+if ! git rev-parse --git-dir > /dev/null 2>&1; then
+    echo -e "${RED}Error: Not a git repository${NC}" >&2
+    exit 1
+fi
+
+# Get the last tag
+LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
+
+if [ -z "$LAST_TAG" ]; then
+    echo -e "${YELLOW}Warning: No tags found. Using all commits.${NC}" >&2
+    COMMIT_RANGE=""
+else
+    echo -e "${GREEN}Last tag: $LAST_TAG${NC}" >&2
+    COMMIT_RANGE="${LAST_TAG}..HEAD"
+fi
+
+# Get commits since last tag (or all commits if no tag)
+if [ -z "$COMMIT_RANGE" ]; then
+    COMMITS=$(git log --pretty=format:"%s" --no-merges)
+else
+    COMMITS=$(git log --pretty=format:"%s" --no-merges "$COMMIT_RANGE")
+fi
+
+if [ -z "$COMMITS" ]; then
+    echo -e "${YELLOW}No commits found since last tag.${NC}" >&2
+    exit 0
+fi
+
+# Initialize category arrays
+declare -a ADDED=()
+declare -a FIXED=()
+declare -a CHANGED=()
+declare -a REMOVED=()
+declare -a OTHER=()
+
+# Categorize commits
+while IFS= read -r commit; do
+    [ -z "$commit" ] && continue
+    
+    # Normalize for matching
+    lower_commit=$(echo "$commit" | tr '[:upper:]' '[:lower:]')
+    
+    if [[ "$lower_commit" =~ ^(feat|add|create|implement|introduce) ]] || \
+       [[ "$lower_commit" =~ (add|adds|added|adding|create|creates|created|implement|implements|implemented|feature|new) ]]; then
+        ADDED+=("$commit")
+    elif [[ "$lower_commit" =~ ^(fix|bugfix|hotfix|patch) ]] || \
+         [[ "$lower_commit" =~ (fix|fixes|fixed|fixing|bug|bugs|resolve|resolves|resolved|patch|patches) ]]; then
+        FIXED+=("$commit")
+    elif [[ "$lower_commit" =~ ^(remove|delete|drop|revert) ]] || \
+         [[ "$lower_commit" =~ (remove|removes|removed|removing|delete|deletes|deleted|deleting|drop|drops|dropped|revert|reverts|reverted) ]]; then
+        REMOVED+=("$commit")
+    elif [[ "$lower_commit" =~ ^(update|change|modify|refactor|improve|enhance|upgrade|bump) ]] || \
+         [[ "$lower_commit" =~ (update|updates|updated|updating|change|changes|changed|changing|modify|modifies|modified|modifying|refactor|refactored|improve|improves|improved|enhance|enhances|enhanced|upgrade|upgrades|upgraded|bump|bumps|bumped) ]]; then
+        CHANGED+=("$commit")
+    else
+        OTHER+=("$commit")
+    fi
+done <<< "$COMMITS"
+
+# Generate changelog content
+generate_changelog() {
+    local date_str
+    date_str=$(date +%Y-%m-%d)
+    
+    echo "## [Unreleased] - $date_str"
+    echo ""
+    
+    if [ ${#ADDED[@]} -gt 0 ]; then
+        echo "### Added"
+        printf -- "- %s\n" "${ADDED[@]}"
+        echo ""
+    fi
+    
+    if [ ${#FIXED[@]} -gt 0 ]; then
+        echo "### Fixed"
+        printf -- "- %s\n" "${FIXED[@]}"
+        echo ""
+    fi
+    
+    if [ ${#CHANGED[@]} -gt 0 ]; then
+        echo "### Changed"
+        printf -- "- %s\n" "${CHANGED[@]}"
+        echo ""
+    fi
+    
+    if [ ${#REMOVED[@]} -gt 0 ]; then
+        echo "### Removed"
+        printf -- "- %s\n" "${REMOVED[@]}"
+        echo ""
+    fi
+    
+    if [ ${#OTHER[@]} -gt 0 ]; then
+        echo "### Other"
+        printf -- "- %s\n" "${OTHER[@]}"
+        echo ""
+    fi
+}
+
+# Main output logic
+if [ "$OUTPUT_TO_STDOUT" = true ]; then
+    generate_changelog
+else
+    # Check if CHANGELOG.md exists and prepend new content
+    NEW_CONTENT=$(generate_changelog)
+    
+    if [ -f "$CHANGELOG_FILE" ]; then
+        # Prepend new section to existing changelog
+        {
+            echo "# Changelog"
+            echo ""
+            echo "$NEW_CONTENT"
+            echo ""
+            # Remove the old "# Changelog" header if present and append rest
+            tail -n +3 "$CHANGELOG_FILE" 2>/dev/null | sed 's/^# Changelog$//' | sed '/^$/!b' || true
+        } > "${CHANGELOG_FILE}.tmp" && mv "${CHANGELOG_FILE}.tmp" "$CHANGELOG_FILE"
+    else
+        #