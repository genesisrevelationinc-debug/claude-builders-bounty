 ```diff
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,163 @@
+#!/usr/bin/env bash
+#
+# changelog.sh — Generate a structured CHANGELOG.md from git history
+#
+# Usage: bash changelog.sh
+#        bash changelog.sh --output custom.md
+#        bash changelog.sh --since-tag v1.0.0
+#
+
+set -euo pipefail
+
+# ── Configuration ───────────────────────────────────────────────────────────
+
+OUTPUT_FILE="CHANGELOG.md"
+SINCE_TAG=""
+
+# Parse arguments
+while [[ $# -gt 0 ]]; do
+    case "$1" in
+        --output|-o)
+            OUTPUT_FILE="$2"
+            shift 2
+            ;;
+        --since-tag|-t)
+            SINCE_TAG="$2"
+            shift 2
+            ;;
+        --help|-h)
+            echo "Usage: bash changelog.sh [OPTIONS]"
+            echo ""
+            echo "Options:"
+            echo "  -o, --output <file>     Output file (default: CHANGELOG.md)"
+            echo "  -t, --since-tag <tag>     Use commits since this tag"
+            echo "  -h, --help              Show this help message"
+            exit 0
+            ;;
+        *)
+            echo "Unknown option: $1" >&2
+            exit 1
+            ;;
+    esac
+done
+
+# ── Helpers ─────────────────────────────────────────────────────────────────
+
+# Find the most recent git tag
+get_latest_tag() {
+    git describe --tags --abbrev=0 2>/dev/null || echo ""
+}
+
+# Get commits since a given reference (tag or empty for all)
+get_commits_since() {
+    local ref="$1"
+    if [[ -n "$ref" ]]; then
+        git log "${ref}..HEAD" --pretty=format:"%s" 2>/dev/null || true
+    else
+        git log --pretty=format:"%s" 2>/dev/null || true
+    fi
+}
+
+# Categorize a commit message into a section
+categorize_commit() {
+    local msg="$1"
+    local lower
+    lower=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
+
+    # Check for conventional commit prefixes
+    if [[ "$lower" =~ ^(feat|add|new|introduce|implement) ]]; then
+        echo "added"
+    elif [[ "$lower" =~ ^(fix|bugfix|hotfix|patch|resolve) ]]; then
+        echo "fixed"
+    elif [[ "$lower" =~ ^(remove|delete|drop|revert) ]]; then
+        echo "removed"
+    elif [[ "$lower" =~ ^(update|change|modify|refactor|improve|enhance|upgrade) ]]; then
+        echo "changed"
+    else
+        # Fallback: keyword matching anywhere in the message
+        if [[ "$lower" =~ (fix|bug|issue|crash|error|broken|repair) ]]; then
+            echo "fixed"
+        elif [[ "$lower" =~ (add|introduce|support|enable|create) ]]; then
+            echo "added"
+        elif [[ "$lower" =~ (remove|delete|drop|disable|deprecate) ]]; then
+            echo "removed"
+        else
+            echo "changed"
+        fi
+    fi
+}
+
+# ── Main ────────────────────────────────────────────────────────────────────
+
+main() {
+    # Validate we're in a git repo
+    if ! git rev-parse --git-dir > /dev/null 2>&1; then
+        echo "Error: Not a git repository." >&2
+        exit 1
+    fi
+
+    # Determine the reference commit
+    if [[ -z "$SINCE_TAG" ]]; then
+        SINCE_TAG=$(get_latest_tag)
+    fi
+
+    local tag_info=""
+    if [[ -n "$SINCE_TAG" ]]; then
+        tag_info="since $SINCE_TAG"
+    else
+        tag_info="(all commits)"
+    fi
+
+    echo "Generating changelog $tag_info..."
+
+    # Collect and categorize commits
+    local added=() fixed=() changed=() removed=()
+
+    while IFS= read -r commit; do
+        [[ -z "$commit" ]] && continue
+
+        # Skip merge commits and common noise
+        [[ "$commit" =~ ^Merge[[:space:]] ]] && continue
+        [[ "$commit" =~ ^Revert[[:space:]] ]] && continue
+
+        local category
+        category=$(categorize_commit "$commit")
+
+        case "$category" in
+            added)   added+=("$commit") ;;
+            fixed)   fixed+=("$commit") ;;
+            removed) removed+=("$commit") ;;
+            changed) changed+=("$commit") ;;
+        esac
+    done < <(get_commits_since "$SINCE_TAG")
+
+    # Generate the changelog
+    {
+        echo "# Changelog"
+        echo ""
+        echo "All notable changes to this project will be documented in this file."
+        echo ""
+        echo "## [Unreleased]"
+        echo ""
+
+        if [[ ${#added[@]} -gt 0 ]]; then
+            echo "### Added"
+            for c in "${added[@]}"; do
+                echo "- $c"
+            done
+            echo ""
+        fi
+
+        if [[ ${#changed[@]} -gt 0 ]]; then
+            echo "### Changed"
+            for c in "${changed[@]}"; do
+                echo "- $c"
+            done
+            echo ""
+        fi
+
+        if [[ ${#fixed[@]} -gt 0 ]]; then
+            echo "### Fixed"
+            for c in "${fixed[@]}"; do
+                echo "- $c"
+            done
+            echo ""
+        fi
+
+        if [[ ${#removed[@]} -gt 0 ]]; then
+            echo "### Removed"
+            for c in "${removed[@]}"; do
+                echo "- $c"
+            done
+            echo ""
+        fi
+
+        if [[ ${#added[@]} -eq 0 && ${#changed[@]} -eq 0 && ${#fixed[@]} -eq 0 && ${#removed[@]} -eq 0 ]]; then
+            echo "*No changes found.*"
+            echo ""
+        fi
+
+        echo "---"
+        echo ""
+        echo "*Generated automatically by [changelog.sh](changelog.sh).*"
+
+    } > "$OUTPUT_FILE