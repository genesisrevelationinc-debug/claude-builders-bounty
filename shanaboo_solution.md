 ```diff
--- /dev/null
+++ b/generate-changelog
@@ -0,0 +1,3 @@
+#!/usr/bin/env bash
+# Generate a structured CHANGELOG.md from git history
+exec "$(dirname "$0")/changelog.sh" "$@"
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,155 @@
+#!/usr/bin/env bash
+#
+# changelog.sh — Generate a structured CHANGELOG.md from git history
+#
+# Usage:
+#   bash changelog.sh              # Generate CHANGELOG.md from last tag
+#   bash changelog.sh --dry-run    # Preview without writing file
+#   bash changelog.sh --all        # Use all commits (ignore tags)
+#
+
+set -euo pipefail
+
+SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
+OUTPUT_FILE="${CHANGELOG_OUTPUT:-CHANGELOG.md}"
+DRY_RUN=false
+USE_ALL=false
+
+# Parse arguments
+for arg in "$@"; do
+  case "$arg" in
+    --dry-run) DRY_RUN=true ;;
+    --all) USE_ALL=true ;;
+  esac
+done
+
+# Colors for terminal output
+RED='\033[0;31m'
+GREEN='\033[0;32m'
+YELLOW='\033[1;33m'
+BLUE='\033[0;34m'
+NC='\033[0m' # No Color
+
+log_info() { echo -e "${BLUE}ℹ${NC} $1"; }
+log_success() { echo -e "${GREEN}✓${NC} $1"; }
+log_warn() { echo -e "${YELLOW}⚠${NC} $1"; }
+log_error() { echo -e "${RED}✗${NC} $1"; }
+
+# Get the latest git tag
+get_latest_tag() {
+  git describe --tags --abbrev=0 2>/dev/null || echo ""
+}
+
+# Get commits since a given ref (or all if no ref)
+get_commits() {
+  local since_ref="$1"
+  if [[ -n "$since_ref" ]]; then
+    git log "${since_ref}..HEAD" --pretty=format:"%s" 2>/dev/null || true
+  else
+    git log --pretty=format:"%s" 2>/dev/null || true
+  fi
+}
+
+# Categorize a single commit message
+categorize_commit() {
+  local msg="$1"
+  local lower_msg
+  lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
+
+  # Skip merge commits and revert markers for categorization
+  if [[ "$msg" =~ ^[Mm]erge[[:space:]] ]]; then
+    echo "skip"
+    return
+  fi
+
+  # Check for conventional commit prefixes first
+  if [[ "$lower_msg" =~ ^(feat|add|introduce|implement|create|new)[:\(] ]] || \
+     [[ "$lower_msg" =~ ^(feat|add|introduce|implement|create|new)[[:space:]] ]]; then
+    echo "added"
+  elif [[ "$lower_msg" =~ ^(fix|bugfix|hotfix|patch|resolve)[:\(] ]] || \
+        [[ "$lower_msg" =~ ^(fix|bugfix|hotfix|patch|resolve)[[:space:]] ]]; then
+    echo "fixed"
+  elif [[ "$lower_msg" =~ ^(remove|delete|drop|eliminate|deprecate|clean)[:\(] ]] || \
+        [[ "$lower_msg" =~ ^(remove|delete|drop|eliminate|deprecate|clean)[[:space:]] ]]; then
+    echo "removed"
+  elif [[ "$lower_msg" =~ ^(update|change|modify|refactor|improve|enhance|upgrade|rework)[:\(] ]] || \
+        [[ "$lower_msg" =~ ^(update|change|modify|refactor|improve|enhance|upgrade|rework)[[:space:]] ]]; then
+    echo "changed"
+  else
+    # Fallback: keyword matching anywhere in message
+    if [[ "$lower_msg" =~ (add|adds|added|adding|feature|feat|introduce|implement|create|new) ]]; then
+      echo "added"
+    elif [[ "$lower_msg" =~ (fix|fixes|fixed|fixing|bug|bugfix|patch|resolve|resolves|resolved) ]]; then
+      echo "fixed"
+    elif [[ "$lower_msg" =~ (remove|removes|removed|removing|delete|deletes|deleted|deleting|drop|drops|dropped|deprecate|deprecates|deprecated) ]]; then
+      echo "removed"
+    elif [[ "$lower_msg" =~ (update|updates|updated|updating|change|changes|changed|changing|modify|modifies|modified|modifying|refactor|refactored|refactoring|improve|improves|improved|improving|enhance|enhances|enhanced|enhancing|upgrade|upgrades|upgraded|upgrading|rework|reworked) ]]; then
+      echo "changed"
+    else
+      echo "changed"  # Default fallback
+    fi
+  fi
+}
+
+# Generate the changelog content
+generate_changelog() {
+  local since_ref="$1"
+  local commits
+  local added=()
+  local fixed=()
+  local changed=()
+  local removed=()
+
+  # Read commits into array
+  mapfile -t commits < <(get_commits "$since_ref")
+
+  if [[ ${#commits[@]} -eq 0 ]] || [[ -z "${commits[0]}" ]]; then
+    return 1
+  fi
+
+  # Categorize each commit
+  for commit in "${commits[@]}"; do
+    [[ -z "$commit" ]] && continue
+    local category
+    category=$(categorize_commit "$commit")
+    [[ "$category" == "skip" ]] && continue
+
+    case "$category" in
+      added) added+=("$commit") ;;
+      fixed) fixed+=("$commit") ;;
+      removed) removed+=("$commit") ;;
+      changed) changed+=("$commit") ;;
+    esac
+  done
+
+  # Build output
+  local output=""
+  local today
+  today=$(date +%Y-%m-%d)
+
+  output+="# Changelog"$'\n\n'
+  output+="All notable changes to this project will be documented in this file."$'\n\n'
+
+  # Determine version header
+