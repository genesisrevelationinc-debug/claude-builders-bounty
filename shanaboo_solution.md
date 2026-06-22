 ```diff
--- /dev/null
+++ b/generate-changelog.sh
@@ -0,0 +1,163 @@
+#!/usr/bin/env bash
+#
+# generate-changelog.sh
+# Generates a structured CHANGELOG.md from git history since the last tag.
+#
+# Usage: bash generate-changelog.sh
+#        ./generate-changelog.sh
+
+set -euo pipefail
+
+# Colors for output
+RED='\033[0;31m'
+GREEN='\033[0;32m'
+YELLOW='\033[1;33m'
+NC='\033[0m' # No Color
+
+# Get the directory where the script is located
+SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
+CHANGELOG_FILE="${SCRIPT_DIR}/CHANGELOG.md"
+
+# Get the latest git tag
+get_latest_tag() {
+    git describe --tags --abbrev=0 2>/dev/null || echo ""
+}
+
+# Get commits since the last tag (or all commits if no tag exists)
+get_commits_since_tag() {
+    local tag="$1"
+    if [ -n "$tag" ]; then
+        git log "${tag}..HEAD" --pretty=format:"%s" --no-merges
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
+    # Added: feat, add, create, introduce, implement, new
+    if echo "$lower_msg" | grep -qE '^(feat|add|create|introduce|implement|new)'; then
+        echo "added"
+    # Fixed: fix, bugfix, hotfix, repair, resolve, patch
+    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|repair|resolve|patch)'; then
+        echo "fixed"
+    # Removed: remove, delete, drop, deprecate, clean
+    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|deprecate|clean)'; then
+        echo "removed"
+    # Changed: update, upgrade, change, refactor, improve, optimize, modify, rework
+    elif echo "$lower_msg" | grep -qE '^(update|upgrade|change|refactor|improve|optimize|modify|rework|enhance)'; then
+        echo "changed"
+    # Default to changed if it has certain keywords
+    elif echo "$lower_msg" | grep -qE '(update|upgrade|refactor|improve|optimize|modify|rework|enhance)'; then
+        echo "changed"
+    # Default to added if it has certain keywords
+    elif echo "$lower_msg" | grep -qE '(add|create|implement|introduce)'; then
+        echo "added"
+    # Default to fixed if it has certain keywords
+    elif echo "$lower_msg" | grep -qE '(fix|repair|resolve|patch)'; then
+        echo "fixed"
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
+    local version
+    local date_str
+    date_str=$(date +%Y-%m-%d)
+
+    if [ -n "$latest_tag" ]; then
+        version="$latest_tag"
+    else
+        version="unreleased"
+    fi
+
+    # Read commits into arrays by category
+    local added_commits=()
+    local fixed_commits=()
+    local changed_commits=()
+    local removed_commits=()
+
+    while IFS= read -r commit; do
+        [ -z "$commit" ] && continue
+
+        local category
+        category=$(categorize_commit "$commit")
+
+        case "$category" in
+            added)   added_commits+=("$commit") ;;
+            fixed)   fixed_commits+=("$commit") ;;
+            changed) changed_commits+=("$commit") ;;
+            removed) removed_commits+=("$commit") ;;
+        esac
+    done < <(get_commits_since_tag "$latest_tag")
+
+    # Generate the changelog content
+    {
+        echo "# Changelog"
+        echo ""
+        echo "All notable changes to this project will be documented in this file."
+        echo ""
+        echo "## [${version}] - ${date_str}"
+        echo ""
+
+        if [ ${#added_commits[@]} -gt 0 ]; then
+            echo "### Added"
+            for commit in "${added_commits[@]}"; do
+                echo "- $commit"
+            done
+            echo ""
+        fi
+
+        if [ ${#changed_commits[@]} -gt 0 ]; then
+            echo "### Changed"
+            for commit in "${changed_commits[@]}"; do
+                echo "- $commit"
+            done
+            echo ""
+        fi
+
+        if [ ${#fixed_commits[@]} -gt 0 ]; then
+            echo "### Fixed"
+            for commit in "${fixed_commits[@]}"; do
+                echo "- $commit"
+            done
+            echo ""
+        fi
+
+        if [ ${#removed_commits[@]} -gt 0 ]; then
+            echo "### Removed"
+            for commit in "${removed_commits[@]}"; do
+                echo "- $commit"
+            done
+            echo ""
+        fi
+    } > "$CHANGELOG_FILE"
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
+    echo -e "${YELLOW}Generating CHANGELOG.md...${NC}"
+
+    generate_changelog
+
+    echo -e "${GREEN}✓ CHANGELOG.md generated successfully at:${NC} $CHANGELOG_FILE"
+}
+
+main "$@"
--- /dev/null
+++ b/SKILL.md
@@ -0,0 +1,42 @@
+# Generate Changelog Skill
+
+Automatically generate a structured `CHANGELOG.md` from your project's git history.
+
+## Setup
+
+1. Copy `generate-changelog.sh` to your project root
+2. Make it executable: `chmod +