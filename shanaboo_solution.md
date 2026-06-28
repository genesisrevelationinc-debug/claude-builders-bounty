 ```diff
--- /dev/null
+++ b/generate-changelog.sh
@@ -0,0 +1,155 @@
+#!/usr/bin/env bash
+#
+# generate-changelog.sh
+# Automatically generates a structured CHANGELOG.md from git history.
+# Fetches commits since the last git tag and categorizes them.
+#
+# Usage: bash generate-changelog.sh
+#
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
+echo -e "${GREEN}🔍 Generating CHANGELOG...${NC}"
+
+# Check if we're in a git repository
+if ! git rev-parse --git-dir > /dev/null 2>&1; then
+    echo -e "${RED}Error: Not a git repository.${NC}"
+    exit 1
+fi
+
+# Get the latest tag
+LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
+
+if [ -z "$LATEST_TAG" ]; then
+    echo -e "${YELLOW}⚠️  No tags found. Using all commits.${NC}"
+    COMMIT_RANGE=""
+else
+    echo -e "${GREEN}📌 Latest tag: $LATEST_TAG${NC}"
+    COMMIT_RANGE="${LATEST_TAG}..HEAD"
+fi
+
+# Get commits since last tag (or all commits if no tag)
+if [ -z "$COMMIT_RANGE" ]; then
+    COMMITS=$(git log --pretty=format:"%H|%s|%ad" --date=short 2>/dev/null || echo "")
+else
+    COMMITS=$(git log "$COMMIT_RANGE" --pretty=format:"%H|%s|%ad" --date=short 2>/dev/null || echo "")
+fi
+
+if [ -z "$COMMITS" ]; then
+    echo -e "${YELLOW}⚠️  No commits found since last tag.${NC}"
+    exit 0
+fi
+
+# Initialize arrays for categories
+declare -a ADDED=()
+declare -a FIXED=()
+declare -a CHANGED=()
+declare -a REMOVED=()
+declare -a OTHER=()
+
+# Categorize commits based on conventional commit patterns
+while IFS= read -r line; do
+    [ -z "$line" ] && continue
+    
+    HASH=$(echo "$line" | cut -d'|' -f1)
+    MESSAGE=$(echo "$line" | cut -d'|' -f2)
+    DATE=$(echo "$line" | cut -d'|' -f3)
+    
+    # Extract the subject (first line of commit message)
+    SUBJECT="$MESSAGE"
+    
+    # Categorize based on conventional commit prefixes and keywords
+    if [[ "$SUBJECT" =~ ^[Ff]eat(\(.*\))?: ]] || \
+       [[ "$SUBJECT" =~ ^[Aa]dd ]] || \
+       [[ "$SUBJECT" =~ ^[Nn]ew ]] || \
+       [[ "$SUBJECT" =~ ^[Ii]ntroduce ]] || \
+       [[ "$SUBJECT" =~ ^[Ii]mplement ]]; then
+        ADDED+=("- $SUBJECT")
+    elif [[ "$SUBJECT" =~ ^[Ff]ix(\(.*\))?: ]] || \
+         [[ "$SUBJECT" =~ ^[Bb]ugfix ]] || \
+         [[ "$SUBJECT" =~ ^[Rr]esolve ]] || \
+         [[ "$SUBJECT" =~ ^[Cc]orrect ]] || \
+         [[ "$SUBJECT" =~ ^[Pp]atch ]]; then
+        FIXED+=("- $SUBJECT")
+    elif [[ "$SUBJECT" =~ ^[Rr]emove(\(.*\))?: ]] || \
+         [[ "$SUBJECT" =~ ^[Dd]elete ]] || \
+         [[ "$SUBJECT" =~ ^[Rr]emove ]] || \
+         [[ "$SUBJECT" =~ ^[Dd]rop ]] || \
+         [[ "$SUBJECT" =~ ^[Uu]ninstall ]]; then
+        REMOVED+=("- $SUBJECT")
+    elif [[ "$SUBJECT" =~ ^[Cc]hange(\(.*\))?: ]] || \
+         [[ "$SUBJECT" =~ ^[Uu]pdate ]] || \
+         [[ "$SUBJECT" =~ ^[Mm]odify ]] || \
+         [[ "$SUBJECT" =~ ^[Rr]efactor ]] || \
+         [[ "$SUBJECT" =~ ^[Rr]ewrite ]] || \
+         [[ "$SUBJECT" =~ ^[Mm]igrate ]] || \
+         [[ "$SUBJECT" =~ ^[Bb]ump ]] || \
+         [[ "$SUBJECT" =~ ^[Uu]pgrade ]]; then
+        CHANGED+=("- $SUBJECT")
+    else
+        OTHER+=("- $SUBJECT")
+    fi
+done <<< "$COMMITS"
+
+# Generate the CHANGELOG
+{
+    echo "# Changelog"
+    echo ""
+    echo "All notable changes to this project will be documented in this file."
+    echo ""
+    
+    # Date header
+    TODAY=$(date +%Y-%m-%d)
+    echo "## [Unreleased] - $TODAY"
+    echo ""
+    
+    # Added
+    if [ ${#ADDED[@]} -gt 0 ]; then
+        echo "### Added"
+        printf '%s\n' "${ADDED[@]}"
+        echo ""
+    fi
+    
+    # Changed
+    if [ ${#CHANGED[@]} -gt 0 ]; then
+        echo "### Changed"
+        printf '%s\n' "${CHANGED[@]}"
+        echo ""
+    fi
+    
+    # Fixed
+    if [ ${#FIXED[@]} -gt 0 ]; then
+        echo "### Fixed"
+        printf '%s\n' "${FIXED[@]}"
+        echo ""
+    fi
+    
+    # Removed
+    if [ ${#REMOVED[@]} -gt 0 ]; then
+        echo "### Removed"
+        printf '%s\n' "${REMOVED[@]}"
+        echo ""
+    fi
+    
+    # Other (uncategorized)
+    if [ ${#OTHER[@]} -gt 0 ]; then
+        echo "### Other"
+        printf '%s\n' "${OTHER[@]}"
+        echo ""
+    fi
+    
+    echo "---"
