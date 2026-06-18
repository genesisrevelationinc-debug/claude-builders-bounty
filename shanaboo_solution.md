```diff
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,148 @@
+#!/usr/bin/env bash
+set -euo pipefail
+
+# ──────────────────────────────────────────────
+# changelog.sh — Generate structured CHANGELOG.md from git history
+# ──────────────────────────────────────────────
+
+OUTPUT_FILE="${1:-CHANGELOG.md}"
+
+# Ensure we're in a git repo
+if ! git rev-parse --git-dir > /dev/null 2>&1; then
+  echo "Error: Not inside a git repository." >&2
+  exit 1
+fi
+
+# Determine the range of commits to include
+LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || true)
+
+if [[ -n "$LAST_TAG" ]]; then
+  RANGE="${LAST_TAG}..HEAD"
+  echo "→ Found last tag: $LAST_TAG — collecting commits since then"
+else
+  RANGE="HEAD"
+  echo "→ No tags found — collecting all commits"
+fi
+
+# Collect commits (one per line: hash|subject)
+COMMITS=$(git log "$RANGE" --no-merges --pretty=format:'%h|%s')
+
+if [[ -z "$COMMITS" ]]; then
+  echo "→ No new commits since last tag. Nothing to do."
+  exit 0
+fi
+
+# Categorisation arrays
+declare -a ADDED=()
+declare -a FIXED=()
+declare -a CHANGED=()
+declare -a REMOVED=()
+declare -a OTHER=()
+
+# Categorise each commit based on conventional-commit prefixes
+while IFS='|' read -r hash subject; do
+  # Trim leading whitespace
+  subject="${subject#"${subject%%[![:space:]]*}"}"
+
+  # Extract conventional commit type if present
+  if [[ "$subject" =~ ^([a-zA-Z]+)(\(.*\))?!?:[[:space:]]+(.*) ]]; then
+    type="${BASH_REMATCH[1],,}"   # lowercase
+    description="${BASH_REMATCH[3]}"
+  else
+    type="other"
+    description="$subject"
+  fi
+
+  entry="- ${description} (${hash})"
+
+  case "$type" in
+    feat)       ADDED+=("$entry")   ;;
+    fix)        FIXED+=("$entry")   ;;
+    refactor|perf|style|chore|ci|build|test|docs)
+                CHANGED+=("$entry") ;;
+    remove|revert)
+                REMOVED+=("$entry") ;;
+    *)          OTHER+=("$entry")   ;;
+  esac
+done <<< "$COMMITS"
+
+# Build the changelog
+{
+  echo "# Changelog"
+  echo ""
+  echo "## [Unreleased]"
+  echo ""
+
+  print_section() {
+    local title="$1"
+    shift
+    local entries=("$@")
+    if [[ ${#entries[@]} -gt 0 ]]; then
+      echo "### $title"
+      echo ""
+      for e in "${entries[@]}"; do
+        echo "$e"
+      done
+      echo ""
+    fi
+  }
+
+  print_section "Added"   "${ADDED[@]}"
+  print_section "Fixed"   "${FIXED[@]}"
+  print_section "Changed" "${CHANGED[@]}"
+  print_section "Removed" "${REMOVED[@]}"
+
+  # Dump uncategorised commits into Changed if any
+  if [[ ${#OTHER[@]} -gt 0 ]]; then
+    echo "### Changed"
+    echo ""
+    for e in "${OTHER[@]}"; do
+      echo "$e"
+    done
+    echo ""
+  fi
+
+  # If the file already exists, prepend the new content before the previous
+  # unreleased block (or just overwrite if the user prefers — here we prepend).
+} > "$OUTPUT_FILE.tmp"
+
+# If an existing CHANGELOG.md exists, merge the new content on top
+if [[ -f "$OUTPUT_FILE" ]]; then
+  # Read existing file, skip the first two lines (# Changelog + blank) and
+  # the ## [Unreleased] header, then append everything else after our new block.
+  TAIL_CONTENT=$(tail -n +4 "$OUTPUT_FILE" 2>/dev/null || true)
+  {
+    cat "$OUTPUT_FILE.tmp"
+    if [[ -n "$TAIL_CONTENT" ]]; then
+      echo "$TAIL_CONTENT"
+    fi
+  } > "$OUTPUT_FILE"
+  rm "$OUTPUT_FILE.tmp"
+else
+  mv "$OUTPUT_FILE.tmp" "$OUTPUT_FILE"
+fi
+
+echo "✅ CHANGELOG.md generated successfully!"
+echo "   $(wc -l < "$OUTPUT_FILE") lines written."
+echo ""
+echo "   Preview:"
+echo "   ───────────────────────────────"
+head -20 "$OUTPUT_FILE"
+echo "   ───────────────────────────────"
--- /dev/null
+++ b/SKILL.md
@@ -0,0 +1,42 @@
+---
+name: generate-changelog
+description: Generate a structured CHANGELOG.md from git history since the last tag
+---
+
+# Generate Changelog Skill
+
+This skill generates a structured `CHANGELOG.md` from the project's git history.
+
+## Trigger
+
+Type `/generate-changelog` in Claude Code, or run `bash changelog.sh` directly.
+
+## What it does
+
+1. Finds the most recent git tag
+2. Collects all commits since that tag (or all commits if no tag exists)
+3. Auto-categorises commits into:
+   - **Added** — commits starting with `feat:`
+   - **Fixed** — commits starting with `fix:`
+   - **Changed** — commits starting with `refactor:`, `perf:`, `style:`, `chore:`, `ci:`, `build:`, `test:`, `docs:`
+   - **Removed** — commits starting with `remove:` or `revert:`
+4. Outputs a properly formatted `CHANGELOG.md` (or merges into an existing one)
+
+## Usage
+
