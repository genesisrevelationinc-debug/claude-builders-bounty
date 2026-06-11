 ```diff
--- /dev/null
+++ b/generate-changelog
@@ -0,0 +1,3 @@
+#!/bin/bash
+# Shortcut to run the changelog generator
+exec bash "$(dirname "$0")/changelog.sh" "$@"
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,168 @@
+#!/bin/bash
+#
+# changelog.sh — Generate a structured CHANGELOG.md from git history
+#
+# Usage:
+#   bash changelog.sh              # Generate CHANGELOG.md from commits since last tag
+#   bash changelog.sh --all        # Regenerate full CHANGELOG from all commits
+#   bash changelog.sh --dry-run    # Preview without writing to file
+#
+# Requirements: git
+
+set -euo pipefail
+
+# ── Configuration ──────────────────────────────────────────────────────────
+
+OUTPUT_FILE="CHANGELOG.md"
+VERSION=""
+DRY_RUN=false
+ALL_COMMITS=false
+
+# ── Parse arguments ──────────────────────────────────────────────────────────
+
+while [[ $# -gt 0 ]]; do
+    case "$1" in
+        --dry-run) DRY_RUN=true; shift ;;
+        --all)     ALL_COMMITS=true; shift ;;
+        --version) VERSION="$2"; shift 2 ;;
+        *)         echo "Unknown option: $1" >&2; exit 1 ;;
+    esac
+done
+
+# ── Helpers ──────────────────────────────────────────────────────────────────
+
+get_last_tag() {
+    git describe --tags --abbrev=0 2>/dev/null || echo ""
+}
+
+get_commits_since() {
+    local ref="$1"
+    if [[ -n "$ref" ]]; then
+        git log "$ref"..HEAD --pretty=format:"%s" --no-merges
+    else
+        git log --pretty=format:"%s" --no-merges
+    fi
+}
+
+categorize_commit() {
+    local msg="$1"
+    local lower
+    lower=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
+
+    # Check for conventional commit prefixes first
+    if [[ "$lower" =~ ^feat(\(.+\))?: ]]; then
+        echo "added"
+        return
+    elif [[ "$lower" =~ ^fix(\(.+\))?: ]]; then
+        echo "fixed"
+        return
+    elif [[ "$lower" =~ ^(chore|refactor|perf|style|docs|test|build|ci|revert)(\(.+\))?: ]]; then
+        echo "changed"
+        return
+    elif [[ "$lower" =~ ^(remove|delete|drop)(\(.+\))?: ]]; then
+        echo "removed"
+        return
 Diseñador de Moda
+    fi
+
+    # Fallback: keyword-based categorization
+    case "$lower" in
+        *"add"* | *"implement"* | *"introduce"* | *"create"* | *"new "*)
+            echo "added" ;;
+        *"fix"* | *"resolve"* | *"patch"* | *"correct"* | *"repair"*)
+            echo "fixed" ;;
+        *"remove"* | *"delete"* | *"drop"* | *"deprecate"*)
+            echo "removed" ;;
+        *"update"* | *"change"* | *"modify"* | *"refactor"* | *"improve"* | *"enhance"*)
+            echo "changed" ;;
+        *)
+            echo "changed" ;;  # default bucket
+    esac
+}
+
+format_commit() {
+    local msg="$1"
+    # Strip conventional commit prefix for cleaner output
+    local clean
+    clean=$(echo "$msg" | sed -E 's/^(feat|fix|chore|refactor|perf|style|docs|test|build|ci|revert)(\([^)]+\))?:\s*//')
+    echo "- $clean"
+}
+
+generate_changelog() {
+    local last_tag
+    local commits
+    local added=()
+    local fixed=()
+    local changed=()
+    local removed=()
+
+    if $ALL_COMMITS; then
+        last_tag=""
+        echo "Generating full changelog from all commits..." >&2
+    else
+        last_tag=$(get_last_tag)
+        if [[ -n "$last_tag" ]]; then
+            echo "Generating changelog since $last_tag..." >&2
+        else
+            echo "No tags found. Generating changelog from all commits..." >&2
+        fi
+    fi
+
+    # Read commits into array
+    mapfile -t commits < <(get_commits_since "$last_tag")
+
+    if [[ ${#commits[@]} -eq 0 ]]; then
+        echo "No commits found." >&2
+        return
+    fi
+
+    for commit in "${commits[@]}"; do
+        [[ -z "$commit" ]] && continue
+        local category
+        category=$(categorize_commit "$commit")
+        case "$category" in
+            added)   added+=("$(format_commit "$commit")") ;;
+            fixed)   fixed+=("$(format_commit "$commit")") ;;
+            changed) changed+=("$(format_commit "$commit")") ;;
+            removed) removed+=("$(format_commit "$commit")") ;;
+        esac
+    done
+
+    # Build output
+    local output=""
+    local date_str
+    date_str=$(date +%Y-%m-%d)
+
+    if [[ -n "$VERSION" ]]; then
+        output+="## [$VERSION] - $date_str"$'\n\n'
+    else
+        output+="## [Unreleased] - $date_str"$'\n\n'
+    fi
+
+    if [[ ${#added[@]} -gt 0 ]]; then
+        output+="### Added"$'\n'
+        printf '%s\n' "${added[@]}" >> /dev/null 2>&1 || true
+        for item in "${added[@]}"; do output+="$item"$'\n'; done
+        output+=$'\n'
+    fi
+
+    if [[ ${#changed[@]} -gt 0 ]]; then
+        output+="### Changed"$'\n'
+        for item in "${changed[@]}"; do output+="$item"$'\n'; done
+        output+=$'\n'
+    fi
+
+    if [[ ${#fixed[@]} -gt 0 ]]; then
+        output+="### Fixed"$'\n'
+        for item in "${fixed[@]}"; do output+="$item"$'\n'; done
+        output+=$'\n'
