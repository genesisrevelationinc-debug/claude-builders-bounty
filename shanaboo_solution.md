Based on the issue, I need to create a Claude Code agent that reviews PRs and posts structured Markdown comments. Since the repo only has README.md and LICENSE, I'll create the necessary files for the agent.

```diff
--- /dev/null
+++ b/claude-review
@@ -0,0 +1,186 @@
+#!/usr/bin/env bash
+# Claude Code PR Review Agent
+# Usage: claude-review --pr https://github.com/owner/repo/pull/123
+#        claude-review --diff <file> (for local diff files)
+
+set -euo pipefail
+
+# Colors for output
+RED='\033[0;31m'
+GREEN='\033[0;32m'
+YELLOW='\033[1;33m'
+BLUE='\033[0;34m'
+NC='\033[0m' # No Color
+
+print_usage() {
+    cat << EOF
+Usage: claude-review [OPTIONS]
+
+Options:
+  --pr <URL>         GitHub PR URL (e.g., https://github.com/owner/repo/pull/123)
+  --diff <FILE>      Path to a local diff/patch file
+  --output <FILE>    Write review to file instead of stdout
+  --post-comment     Post the review as a PR comment (requires GITHUB_TOKEN)
+  --help             Show this help message
+
+Examples:
+  claude-review --pr https://github.com/owner/repo/pull/123
+  claude-review --diff changes.patch --output review.md
+  claude-review --pr https://github.com/owner/repo/pull/123 --post-comment
+EOF
+}
+
+# Parse arguments
+PR_URL=""
+DIFF_FILE=""
+OUTPUT_FILE=""
+POST_COMMENT=false
+
+while [[ $# -gt 0 ]]; do
+    case "$1" in
+        --pr)
+            PR_URL="$2"
+            shift 2
+            ;;
+        --diff)
+            DIFF_FILE="$2"
+            shift 2
+            ;;
+        --output)
+            OUTPUT_FILE="$2"
+            shift 2
+            ;;
+        --post-comment)
+            POST_COMMENT=true
+            shift
+            ;;
+        --help)
+            print_usage
+            exit 0
+            ;;
+        *)
+            echo -e "${RED}Unknown option: $1${NC}"
+            print_usage
+            exit 1
+            ;;
+    esac
+done
+
+if [[ -z "$PR_URL" && -z "$DIFF_FILE" ]]; then
+    echo -e "${RED}Error: Either --pr or --diff must be provided${NC}"
+    print_usage
+    exit 1
+fi
+
+# Fetch PR diff if URL provided
+TEMP_DIR=$(mktemp -d)
+trap 'rm -rf "$TEMP_DIR"' EXIT
+
+DIFF_PATH=""
+
+if [[ -n "$PR_URL" ]]; then
+    echo -e "${BLUE}Fetching PR diff from: $PR_URL${NC}" >&2
+    
+    # Extract owner, repo, and PR number from URL
+    # Supports formats: https://github.com/owner/repo/pull/123
+    if [[ "$PR_URL" =~ github\.com/([^/]+)/([^/]+)/pull/([0-9]+) ]]; then
+        OWNER="${BASH_REMATCH[1]}"
+        REPO="${BASH_REMATCH[2]}"
+        PR_NUMBER="${BASH_REMATCH[3]}"
+    else
+        echo -e "${RED}Error: Invalid GitHub PR URL format${NC}" >&2
+        exit 1
+    fi
+    
+    # Fetch the PR diff using GitHub API
+    API_URL="https://api.github.com/repos/${OWNER}/${REPO}/pulls/${PR_NUMBER}"
+    
+    # Try to get diff via API
+    if command -v curl &> /dev/null; then
+        DIFF_PATH="${TEMP_DIR}/pr.diff"
+        
+        # Fetch PR details first
+        PR_TITLE=$(curl -s "${API_URL}" | grep -o '"title": "[^"]*"' | head -1 | sed 's/"title": "//;s/"$//' || echo "Unknown")
+        
+        # Fetch the actual diff
+        curl -s -H "Accept: application/vnd.github.v3.diff" "${API_URL}" > "$DIFF_PATH" 2>/dev/null || {
+            echo -e "${RED}Error: Failed to fetch PR diff. Check the URL or network.${NC}" >&2
+            exit 1
+        }
+        
+        # Check if we got a valid diff
+        if [[ ! -s "$DIFF_PATH" ]]; then
+            echo -e "${RED}Error: Empty diff received. The PR may not exist or is inaccessible.${NC}" >&2
+            exit 1
+        }
+        
+        echo -e "${GREEN}✓ Fetched diff for PR #${PR_NUMBER}: ${PR_TITLE}${NC}" >&2
+    else
+        echo -e "${RED}Error: curl is required to fetch PR diffs${NC}" >&2
+        exit 1
+    fi
+else
+    DIFF_PATH="$DIFF_FILE"
+    if [[ ! -f "$DIFF_PATH" ]]; then
+        echo -e "${RED}Error: Diff file not found: $DIFF_PATH${NC}" >&2
+        exit 1
+    fi
+fi
+
+# Generate the review using Claude Code
+echo -e "${BLUE}Analyzing diff with Claude Code...${NC}" >&2
+
+REVIEW_PROMPT="You are an expert code reviewer. Analyze the following git diff and produce a structured Markdown review.

## Required Output Format

\`\`\`markdown
# PR Review

## Summary
[2-3 sentences summarizing what this PR changes and its overall impact]

## Identified Risks
- [Risk 1: specific concern with file/line reference]
- [Risk 2: ...]
- [Risk 3: ...]
(If no risks found, state: \"No significant risks identified.\")

## Improvement Suggestions
- [Suggestion 1: actionable improvement]
- [Suggestion 2: ...]
- [Suggestion 3: ...]
(If no suggestions, state: \"No improvement suggestions.\")

## Confidence Score
**Confidence: [Low / Medium / High