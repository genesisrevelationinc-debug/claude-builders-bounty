 ```diff
--- /dev/null
+++ b/generate-changelog
@@ -0,0 +1,3 @@
+#!/usr/bin/env bash
+# Generate a structured CHANGELOG.md from git history
+exec "$(dirname "$0")/changelog.sh" "$@"
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,163 @@
+#!/usr/bin/env bash
+#
+# generate-changelog
+# Automatically generates a structured CHANGELOG.md from a project's git history.
+#
+# Usage:
+#   bash changelog.sh              # Generate CHANGELOG.md
+#   bash changelog.sh --dry-run    # Preview output without writing
+#
+# Features:
+#   - Fetches commits since the last git tag
+#   - Auto-categorizes into: Added / Fixed / Changed / Removed
+#   - Outputs a properly formatted CHANGELOG.md
+#
+
+set -euo pipefail
+
+# ── Configuration ───────────────────────────────────────────────────────────
+
+OUTPUT_FILE="CHANGELOG.md"
+DRY_RUN=false
+
+# ── Parse arguments ─────────────────────────────────────────────────────────
+
+while [[ $# -gt 0 ]]; do
+    case "$1" in
+        --dry-run)
+            DRY_RUN=true
+            shift
+            ;;
+        -h|--help)
+            echo "Usage: bash changelog.sh [--dry-run]"
+            echo ""
+            echo "Generates a structured CHANGELOG.md from git history."
+            echo ""
+            echo "Options:"
+            echo "  --dry-run    Preview output without writing to file"
+            echo "  -h, --help   Show this help message"
+            exit 0
+            ;;
+        *)
+            echo "Unknown option: $1" >&2
+            echo "Use --help for usage information" >&2
+            exit 1
+            ;;
+    esac
+done
+
+# ── Helpers ─────────────────────────────────────────────────────────────────
+
+get_last_tag() {
+    git describe --tags --abbrev=0 2>/dev/null || echo ""
+}
+
+get_commits_since_tag() {
+    local tag="$1"
+    if [[ -n "$tag" ]]; then
+        git log "$tag..HEAD" --pretty=format:"%s" --no-merges 2>/dev/null || true
+    else
+        git log --pretty=format:"%s" --no-merges 2>/dev/null || true
+    fi
+}
+
+get_date() {
+    date +"%Y-%m-%d"
+}
+
+get_version_from_tag() {
+    local tag="$1"
+    if [[ -n "$tag" ]]; then
+        # Remove 'v' prefix if present
+        echo "$tag" | sed 's/^[vV]//'
+    else
+        echo "Unreleased"
+    fi
+}
+
+categorize_commit() {
+    local msg="$1"
+    local lower_msg
+    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
+
+    # Check for conventional commit prefixes first
+    if [[ "$lower_msg" =~ ^(feat|add|introduce|implement|create|new) ]]; then
+        echo "added"
+    elif [[ "$lower_msg" =~ ^(fix|bugfix|hotfix|patch|resolve|correct) ]]; then
+        echo "fixed"
+    elif [[ "$lower_msg" =~ ^(remove|delete|drop|eliminate|deprecate|clean) ]]; then
+        echo "removed"
+    elif [[ "$lower_msg" =~ ^(update|change|modify|refactor|improve|enhance|upgrade|rework) ]]; then
+        echo "changed"
+    else
+        # Fallback: keyword matching anywhere in the message
+        if [[ "$lower_msg" =~ (fix|bug|resolve|patch|correct) ]]; then
+            echo "fixed"
+        elif [[ "$lower_msg" =~ (add|feat|introduce|implement|create|new) ]]; then
+            echo "added"
+        elif [[ "$lower_msg" =~ (remove|delete|drop|eliminate|deprecate) ]]; then
+            echo "removed"
+        else
+            echo "changed"
+        fi
+    fi
+}
+
+# ── Main ────────────────────────────────────────────────────────────────────
+
+# Check if we're in a git repository
+if ! git rev-parse --git-dir > /dev/null 2>&1; then
+    echo "Error: Not a git repository" >&2
+    exit 1
+fi
+
+LAST_TAG=$(get_last_tag)
+VERSION=$(get_version_from_tag "$LAST_TAG")
+DATE=$(get_date)
+
+# Collect commits by category
+declare -A commits_added
+declare -A commits_fixed
+declare -A commits_changed
+declare -A commits_removed
+
+while IFS= read -r commit; do
+    [[ -z "$commit" ]] && continue
+
+    # Skip merge commits and empty lines
+    [[ "$commit" =~ ^Merge ]] && continue
+
+    category=$(categorize_commit "$commit")
+
+    # Clean up the commit message
+    clean_msg=$(echo "$commit" | sed 's/^[a-zA-Z]*://; s/^[a-zA-Z]*(\([^)]*\))://; s/^[ \t]*//; s/[ \t]*$//')
+
+    case "$category" in
+        added)   commits_added["$clean_msg"]=1 ;;
+        fixed)   commits_fixed["$clean_msg"]=1 ;;
+        changed) commits_changed["$clean_msg"]=1 ;;
+        removed) commits_removed["$clean_msg"]=1 ;;
+    esac
+done < <(get_commits_since_tag "$LAST_TAG")
+
+# Build output
+{
+    echo "# Changelog"
+    echo ""
+    echo "All notable changes to this project will be documented in this file."
+    echo ""
+    echo "The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),"
+    echo "and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)."
+    echo ""
+    echo "## [$VERSION] - $DATE"
+    echo ""
+
+    if [[ ${#commits_added[@]} -gt 0 ]]; then
+        echo "### Added"
+        for msg in "${!commits_added[@]}"; do
+            echo "- $msg"
+        done | sort
+        echo ""
+    fi
+
+    if [[ ${#commits_changed[@]} -gt 0 ]]; then
+        echo "### Changed"
+        for msg in "${!commits_changed[@]}";