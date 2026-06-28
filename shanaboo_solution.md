 ```diff
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,166 @@
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
+DATE_FORMAT="%Y-%m-%d"
+
+# Function to print colored messages
+info() {
+    echo -e "${GREEN}[INFO]${NC} $1"
+}
+
+warn() {
+    echo -e "${YELLOW}[WARN]${NC} $1"
+}
+
+error() {
+    echo -e "${RED}[ERROR]${NC} $1"
+}
+
+# Check if we're in a git repository
+if ! git rev-parse --git-dir > /dev/null 2>&1; then
+    error "Not a git repository. Please run this script from a git repository."
+    exit 1
+fi
+
+# Get the latest tag
+LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
+
+if [ -z "$LATEST_TAG" ]; then
+    warn "No tags found. Using all commits."
+    COMMIT_RANGE=""
+else
+    info "Latest tag found: $LATEST_TAG"
+    COMMIT_RANGE="${LATEST_TAG}..HEAD"
+fi
+
+# Get the repository name
+REPO_NAME=$(basename -s .git "$(git remote get-url origin 2>/dev/null || echo "unknown")" 2>/dev/null || echo "unknown")
+
+# Get the current date
+CURRENT_DATE=$(date +"$DATE_FORMAT")
+
+# Arrays to store categorized commits
+declare -a ADDED=()
+declare -a FIXED=()
+declare -a CHANGED=()
+declare -a REMOVED=()
+declare -a OTHER=()
+
+# Function to categorize a commit
+categorize_commit() {
+    local message="$1"
+    local hash="$2"
+    
+    # Clean up the message (remove conventional commit prefixes)
+    local clean_message
+    clean_message=$(echo "$message" | sed -E 's/^(feat|fix|chore|docs|style|refactor|perf|test|build|ci|revert)(\([^)]*\))?:[[:space:]]*//i')
+    
+    # Format: - message (hash)
+    local formatted="- ${clean_message} (${hash})"
+    
+    # Categorize based on conventional commit type or keywords
+    if echo "$message" | grep -qiE '^(feat|add|new|create|introduce)'; then
+        ADDED+=("$formatted")
+    elif echo "$message" | grep -qiE '^(fix|bugfix|hotfix|patch|resolve)'; then
+        FIXED+=("$formatted")
+    elif echo "$message" | grep -qiE '^(refactor|update|modify|change|improve|enhance|optimize)'; then
+        CHANGED+=("$formatted")
+    elif echo "$message" | grep -qiE '^(remove|delete|drop|revert|deprecate)'; then
+        REMOVED+=("$formatted")
+    else
+        # Check for keywords in the message
+        if echo "$message" | grep -qiE '\b(add|added|adding|introduce|new|feature)\b'; then
+            ADDED+=("$formatted")
+        elif echo "$message" | grep -qiE '\b(fix|fixed|fixing|bug|resolve|patch)\b'; then
+            FIXED+=("$formatted")
+        elif echo "$message" | grep -qiE '\b(change|changed|update|updated|modify|modified|refactor|improve|improved|enhance)\b'; then
+            CHANGED+=("$formatted")
+        elif echo "$message" | grep -qiE '\b(remove|removed|delete|deleted|drop|dropped|revert|reverted)\b'; then
+            REMOVED+=("$formatted")
+        else
+            OTHER+=("$formatted")
+        fi
+    fi
+}
+
+# Fetch commits
+if [ -z "$COMMIT_RANGE" ]; then
+    info "Fetching all commits..."
+    COMMITS=$(git log --pretty=format:"%H|%s" --no-merges)
+else
+    info "Fetching commits since $LATEST_TAG..."
+    COMMITS=$(git log "$COMMIT_RANGE" --pretty=format:"%H|%s" --no-merges)
+fi
+
+# Process each commit
+while IFS='|' read -r hash message; do
+    [ -z "$hash" ] && continue
+    categorize_commit "$message" "${hash:0:7}"
+done <<< "$COMMITS"
+
+# Generate CHANGELOG.md
+info "Generating $OUTPUT_FILE..."
+
+{
+    echo "# Changelog"
+    echo ""
+    echo "All notable changes to this project will be documented in this file."
+    echo ""
+    echo "## [Unreleased] - $CURRENT_DATE"
+    echo ""
+    
+    # Output sections only if they have entries
+    if [ ${#ADDED[@]} -gt 0 ]; then
+        echo "### Added"
+        printf '%s\n' "${ADDED[@]}"
+        echo ""
+    fi
+    
+    if [ ${#CHANGED[@]} -gt 0 ]; then
+        echo "### Changed"
+        printf '%s\n' "${CHANGED[@]}"
+        echo ""
+    fi
+    
+    if [ ${#FIXED[@]} -gt 0 ]; then
+        echo "### Fixed"
+        printf '%s\n' "${FIXED[@]}"
+        echo ""
+    fi
+    
+    if [ ${#REMOVED[@]} -gt 0 ]; then
+        echo "### Removed"
+        printf '%s\n' "${REMOVED[@]}"
+        echo ""
+    fi
+    
+    if [ ${#OTHER[@]} -gt 0 ]; then
+        echo "### Other"
+        printf '%s\n' "${OTHER[@]}"
+        echo ""
+    fi
+    
+    # Append existing changelog content if it exists (except the header)
+    if [ -f "$OUTPUT_FILE" ]; then
+        # Extract existing entries (skip the first few lines which are headers)
+        tail -n +10 "$OUTPUT_FILE" 2>/dev/null || true
+    fi
+    
+} > "$OUTPUT_FILE