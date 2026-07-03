Based on the issue, I need to create a bash script `changelog.sh` that generates a structured CHANGELOG.md from git history. Since the repo only has LICENSE and README.md, I'll create the new script file and update the README with setup instructions.

```diff
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,155 @@
+#!/usr/bin/env bash
+#
+# changelog.sh — Generate a structured CHANGELOG.md from git history
+#
+# Usage:
+#   ./changelog.sh                    # writes CHANGELOG.md in current directory
+#   ./changelog.sh -o ../CHANGELOG.md # specify output path
+#   ./changelog.sh -t v1.0.0          # start from a specific tag
+#
+# Requires: git, bash 4+
+
+set -euo pipefail
+
+# ── defaults ──────────────────────────────────────────────
+OUTPUT="CHANGELOG.md"
+START_TAG=""
+REPO_URL=""
+
+# ── helpers ───────────────────────────────────────────────
+usage() {
+  cat <<EOF
+Usage: $(basename "$0") [OPTIONS]
+
+Options:
+  -o FILE     Output file path (default: CHANGELOG.md)
+  -t TAG      Start from a specific git tag (default: latest tag)
+  -h          Show this help message
+
+Examples:
+  $(basename "$0")                     # use latest tag, write CHANGELOG.md
+  $(basename "$0") -o docs/CHANGELOG.md
+  $(basename "$0") -t v2.0.0
+EOF
+  exit 0
+}
+
+die() { echo "ERROR: $*" >&2; exit 1; }
+
+# ── parse args ────────────────────────────────────────────
+while getopts "o:t:h" opt; do
+  case "$opt" in
+    o) OUTPUT="$OPTARG" ;;
+    t) START_TAG="$OPTARG" ;;
+    h) usage ;;
+    *) usage ;;
+  esac
+done
+
+# ── prerequisites ─────────────────────────────────────────
+command -v git >/dev/null 2>&1 || die "git is not installed or not in PATH"
+git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "not inside a git repository"
+
+# ── determine starting point ──────────────────────────────
+if [[ -z "$START_TAG" ]]; then
+  START_TAG=$(git describe --tags --abbrev=0 2>/dev/null) || true
+fi
+
+if [[ -n "$START_TAG" ]]; then
+  RANGE="$START_TAG..HEAD"
+  echo "🔖 Using tag: $START_TAG → HEAD"
+else
+  RANGE=""
+  echo "⚠️  No tags found — collecting all commits"
+fi
+
+# ── collect commits ───────────────────────────────────────
+echo "📦 Gathering commits..."
+
+if [[ -n "$RANGE" ]]; then
+  COMMITS=$(git log "$RANGE" --no-merges --pretty=format:"%s" 2>/dev/null || true)
+else
+  COMMITS=$(git log --no-merges --pretty=format:"%s" 2>/dev/null || true)
+fi
+
+if [[ -z "$COMMITS" ]]; then
+  echo "✅ No new commits since $START_TAG — writing empty changelog"
+fi
+
+# ── categorization ────────────────────────────────────────
+declare -a ADDED=()
+declare -a FIXED=()
+declare -a CHANGED=()
+declare -a REMOVED=()
+declare -a OTHER=()
+
+while IFS= read -r line; do
+  [[ -z "$line" ]] && continue
+
+  # Normalize: trim whitespace
+  msg="${line#"${line%%[![:space:]]*}"}"
+  msg="${msg%"${msg##*[![:space:]]}"}"
+
+  # Categorize by conventional-commit prefix or keyword
+  lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
+
+  if   [[ "$lower_msg" =~ ^(feat|add|added|implement|introduce|create|new)[\ :] ]]; then
+    ADDED+=("$msg")
+  elif [[ "$lower_msg" =~ ^(fix|fixed|bug|patch|resolve|hotfix|repair)[\ :] ]]; then
+    FIXED+=("$msg")
+  elif [[ "$lower_msg" =~ ^(remove|removed|drop|delete|deprecate|retire)[\ :] ]]; then
+    REMOVED+=("$msg")
+  elif [[ "$lower_msg" =~ ^(change|changed|update|refactor|tweak|adjust|improve|enhance|modify|rework|revamp)[\ :] ]]; then
+    CHANGED+=("$msg")
+  else
+    OTHER+=("$msg")
+  fi
+done <<< "$COMMITS"
+
+# ── detect repo URL for link ──────────────────────────────
+REPO_URL=$(git config --get remote.origin.url 2>/dev/null || true)
+if [[ -n "$REPO_URL" ]]; then
+  # Normalize SSH → HTTPS
+  REPO_URL="${REPO_URL#git@}"
+  REPO_URL="${REPO_URL/://}"
+  REPO_URL="${REPO_URL%.git}"
+  if [[ "$REPO_URL" != http* ]]; then
+    REPO_URL="https://$REPO_URL"
+  fi
+fi
+
+# ── assemble changelog ────────────────────────────────────
+TODAY=$(date +%Y-%m-%d)
+
+{
+  echo "# Changelog"
+  echo ""
+  echo "## [Unreleased] — $TODAY"
+  echo ""
+
+  for section in "Added:ADDED" "Fixed:FIXED" "Changed:CHANGED" "Removed:REMOVED"; do
+    label="${section%%:*}"
+    varname="${section##*:}"
+    eval "entries=(\"\${${varname}[@]}\")"
+    if [[ ${#entries[@]} -gt 0 ]]; then
+      echo "### $label"
+      echo ""
+      for entry in "${entries[@]}