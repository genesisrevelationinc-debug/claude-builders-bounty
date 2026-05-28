Based on the issue, I need to create a Claude Code sub-agent that reviews PRs and posts structured Markdown comments. Since the repo only contains README.md and LICENSE, I'll create the necessary files for the agent.

```diff
--- /dev/null
+++ b/claude-review
@@ -0,0 +1,186 @@
+#!/usr/bin/env bash
+# Claude Code PR Review Agent
+# Usage: claude-review --pr https://github.com/owner/repo/pull/123
+#        claude-review --diff <file.diff>
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
+  --pr <URL>        GitHub PR URL (e.g., https://github.com/owner/repo/pull/123)
+  --diff <FILE>     Path to a local diff file
+  --output <FILE>   Write review to file instead of stdout
+  --post-comment    Post the review as a PR comment (requires GITHUB_TOKEN)
+  --help            Show this help message
+
+Examples:
+  claude-review --pr https://github.com/owner/repo/pull/123
+  claude-review --diff changes.diff --output review.md
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
+    case $1 in
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
+            echo -e "${RED}Error: Unknown option $1${NC}"
+            print_usage
+            exit 1
+            ;;
+    esac
+done
+
+# Validate inputs
+if [[ -z "$PR_URL" && -z "$DIFF_FILE" ]]; then
+    echo -e "${RED}Error: Either --pr or --diff must be specified${NC}"
+    print_usage
+    exit 1
+fi
+
+if [[ -n "$PR_URL" && -n "$DIFF_FILE" ]]; then
+    echo -e "${RED}Error: Cannot specify both --pr and --diff${NC}"
+    print_usage
+    exit 1
+fi
+
+# Fetch diff from PR URL
+if [[ -n "$PR_URL" ]]; then
+    echo -e "${BLUE}Fetching PR diff from: $PR_URL${NC}" >&2
+    
+    # Extract owner, repo, and PR number from URL
+    if [[ "$PR_URL" =~ github\.com/([^/]+)/([^/]+)/pull/([0-9]+) ]]; then
+        OWNER="${BASH_REMATCH[1]}"
+        REPO="${BASH_REMATCH[2]}"
+        PR_NUMBER="${BASH_REMATCH[3]}"
+    else
+        echo -e "${RED}Error: Invalid GitHub PR URL format${NC}"
+        echo "Expected: https://github.com/owner/repo/pull/123"
+        exit 1
+    fi
+    
+    # Fetch the diff using GitHub API
+    DIFF_CONTENT=$(curl -sL -H "Accept: application/vnd.github.v3.diff" \
+        "https://api.github.com/repos/${OWNER}/${REPO}/pulls/${PR_NUMBER}" 2>/dev/null || true)
+    
+    if [[ -z "$DIFF_CONTENT" ]]; then
+        echo -e "${RED}Error: Failed to fetch PR diff. The PR may not exist or is private.${NC}"
+        echo "If the repo is private, set GITHUB_TOKEN environment variable."
+        exit 1
+    fi
+    
+    # Save to temp file
+    TEMP_DIFF=$(mktemp)
+    echo "$DIFF_CONTENT" > "$TEMP_DIFF"
+    DIFF_FILE="$TEMP_DIFF"
+    trap "rm -f $TEMP_DIFF" EXIT
+fi
+
+# Check if diff file exists
+if [[ ! -f "$DIFF_FILE" ]]; then
+    echo -e "${RED}Error: Diff file not found: $DIFF_FILE${NC}"
+    exit 1
+fi
+
+echo -e "${GREEN}Analyzing diff...${NC}" >&2
+
+# Generate the review using Claude
+REVIEW=$(claude --print -p "$(cat << PROMPT
+You are a senior code reviewer. Analyze the following git diff and produce a structured Markdown review.
+
+## Review Format
+
+### Summary
+[2-3 sentences summarizing what this PR changes and its overall impact]
+
+### Identified Risks
+- [Risk 1: specific concern with file/line reference]
+- [Risk 2: specific concern with file/line reference]
+
+### Improvement Suggestions
+- [Suggestion 1: actionable improvement]
+- [Suggestion 2: actionable improvement]
+
+### Confidence Score
+**Confidence: [Low/Medium/High]** — [Brief justification]
+
+## Guidelines
+- Be specific — reference actual files and changes from the diff
+- Focus on logic errors, security issues, performance problems, and code quality
+- If the diff is small/simple, say so and adjust confidence accordingly
+- If there are no obvious issues, say so honestly
+- Do NOT comment on formatting unless it's a real problem
+- Keep the tone professional and constructive
+
+Here is the diff to review:
+
+\`\`\`diff
+$(cat "$DIFF_FILE")
+\`\`\`
+PROMPT
+)")
+
+# Output the review
+if [[ -n "$OUTPUT_FILE" ]]; then
+    echo "$REVIEW" > "$OUTPUT_FILE"
+    echo -e "${GREEN}Review saved to: $OUTPUT_FILE${