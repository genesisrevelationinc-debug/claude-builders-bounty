 ```diff
--- /dev/null
+++ b/.github/workflows/claude-review.yml
@@ -0,0 +1,42 @@
+name: Claude PR Review
+
+on:
+  pull_request:
+    types: [opened, synchronize]
+
+jobs:
+  review:
+    runs-on: ubuntu-latest
+    permissions:
+      pull-requests: write
+      contents: read
+    
+    steps:
+      - name: Checkout repository
+        uses: actions/checkout@v4
+        with:
+          fetch-depth: 0
+
+      - name: Set up Python
+        uses: actions/setup-python@v5
+        with:
+          python-version: '3.11'
+
+      - name: Install dependencies
+        run: |
+          pip install -e .
+
+      - name: Get PR diff
+        run: |
+          curl -s -H "Authorization: token ${{ secrets.GITHUB_TOKEN }}" \
+            "${{ github.event.pull_request.diff_url }}" > /tmp/pr.diff
+
+      - name: Run Claude Review
+        env:
+          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
+          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
+          PR_URL: ${{ github.event.pull_request.html_url }}
+        run: |
+          claude-review --pr "$PR_URL" --diff /tmp/pr.diff --post-comment
+--- /dev/null
+++ b/claude_review/__init__.py
@@ -0,0 +1,5 @@
+"""Claude Code PR Review Agent."""
+
+__version__ = "0.1.0"
+
+from .reviewer import ClaudeReviewer
+--- /dev/null
+++	.claude_review/cli.py
@@ -0,0 +1,82 @@
+#!/usr/bin/env python3
+"""CLI entry point for claude-review."""
+
+import argparse
+import os
+import sys
+
+from .reviewer import ClaudeReviewer
+
+
+def main():
+    parser = argparse.ArgumentParser(
+        description="Claude Code PR Review Agent - Analyze PR diffs and generate structured review comments"
+    )
+    parser.add_argument(
+        "--pr",
+        required=True,
+        help="GitHub PR URL (e.g., https://github.com/owner/repo/pull/123)",
+    )
+    parser.add_argument(
+        "--diff",
+        help="Path to PR diff file (optional, will fetch from GitHub if not provided)",
+    )
+    parser.add_argument(
+        "--output",
+        "-o",
+        help="Output file path (default: print to stdout)",
+    )
+    parser.add_argument(
+        "--post-comment",
+        action="store_true",
+        help="Post the review as a comment on the PR (requires GITHUB_TOKEN env var)",
+    )
+    parser.add_argument(
+        "--model",
+        default="claude-sonnet-4-20250514",
+        help="Claude model to use (default: claude-sonnet-4-20250514)",
+    )
+
+    args = parser.parse_args()
+
+    api_key = os.environ.get("ANTHROPIC_API_KEY")
+    if not api_key:
+        print("Error: ANTHROPIC_API_KEY environment variable is required", file=sys.stderr)
+        sys.exit(1)
+
+    reviewer = ClaudeReviewer(api_key=api_key, model=args.model)
+
+    # Get diff content
+    if args.diff:
+        with open(args.diff, "r") as f:
+            diff_content = f.read()
+    else:
+        diff_content = reviewer.fetch_pr_diff(args.pr)
+
+    if not diff_content or not diff_content.strip():
+        print("Error: Could not retrieve PR diff", file=sys.stderr)
+        sys.exit(1)
+
+    # Generate review
+    review = reviewer.review_pr(diff_content, pr_url=args.pr)
+
+    # Output
+    if args.output:
+        with open(args.output, "w") as f:
+            f.write(review)
+        print(f"Review written to {args.output}")
+    else:
+        print(review)
+
+    # Post to GitHub if requested
+    if args.post_comment:
+        github_token = os.environ.get("GITHUB_TOKEN")
+        if not github_token:
+            print("Error: GITHUB_TOKEN environment variable is required for --post-comment", file=sys.stderr)
+            sys.exit(1)
+        reviewer.post_pr_comment(args.pr, review, github_token)
+        print("Review posted as PR comment")
+
+
+if __name__ == "__main__":
+    main()
+--- /dev/null
+++	.claude_review/reviewer.py
@@ -0,0 +1,228 @@
+"""Core PR review logic using Claude API."""
+
+import json
+import re
+import urllib.parse
+import urllib.request
+from typing import Optional
+
+
+class ClaudeReviewer:
+    """Claude-powered PR reviewer that generates structured Markdown reviews."""
+
+    SYSTEM_PROMPT = """You are an expert code reviewer. Analyze the provided PR diff and generate a structured Markdown review with the following sections:
+
+## Summary
+
+A concise 2-3 sentence summary of what this PR changes and its overall purpose.
+
+## Risks
+
+A bulleted list of potential risks, bugs, or issues introduced by this PR. Consider:
+- Security vulnerabilities
+- Performance implications
+- Breaking changes
+- Edge cases not handled
+- Code quality concerns
+
+If no significant risks are identified, state "No major risks identified."
+
+## Suggestions
+
+Actionable improvement suggestions as a bulleted list. Consider:
+- Code refactoring opportunities
+- Better error handling
+- Performance optimizations
+- Documentation improvements
+- Testing gaps
+
+If no suggestions, state "No suggestions — code looks good!"
+
+## Confidence
+
+**Confidence: Low / Medium / High**
+
+Choose based on:
+- **High**: Code is clean, well-tested, follows best practices, minimal risk
+- **Medium**: Some concerns exist but nothing critical; needs minor fixes
+- **Low**: Significant issues, potential bugs, security concerns, or the change is too large/risky to properly assess
+
+Format your response as clean Markdown. Use proper heading levels. Be specific and reference actual code patterns from the diff when relevant."""
+
+    def __init__(self, api_key: str, model: str = "claude-sonnet-4-20250514"):
+        self.api_key = api_key
+        self.model = model
+        self.api_url = "https://api.anthropic.com/v1/messages"
+
+    def fetch_pr_diff(self, pr_url: str) -> str:
+        """Fetch PR diff from GitHub API."""
+        # Convert PR URL to diff URL
+