 ```diff
--- /dev/null
+++ b/.github/workflows/claude-review.yml
@@ -0,0 +1,42 @@
+name: Claude PR Review
+
+on:
+  pull_request:
+    types: [opened, synchronize, reopened]
+
+jobs:
+  review:
+    runs-on: ubuntu-latest
+    permissions:
+      pull-requests: write
+      contents: read
+    
+    steps:
+      - name: Checkout code
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
+        id: get-diff
+        run: |
+          curl -s -H "Authorization: token ${{ secrets.GITHUB_TOKEN }}" \
+            "${{ github.event.pull_request.diff_url }}" > pr.diff
+          echo "diff_file=pr.diff" >> $GITHUB_OUTPUT
+      
+      - name: Run Claude Review
+        env:
+          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
+          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
+          PR_URL: ${{ github.event.pull_request.html_url }}
+        run: |
+          claude-review --pr "$PR_URL" --diff "${{ steps.get-diff.outputs.diff_file }}" --post-comment
+--- /dev/null
+++ b/claude_review/__init__.py
@@ -0,0 +1,5 @@
+"""Claude Code PR Review Agent."""
+
+__version__ = "0.1.0"
+
+from .reviewer import ClaudeReviewer
+--- /dev/null
+++ b/claude_review/__main__.py
@@ -0,0 +1,6 @@
+"""Entry point for running claude-review as a module."""
+
+from .cli import main
+
+if __name__ == "__main__":
+    main()
+--- /dev/null
+++ b/claude_review/cli.py
@@ -0,0 +1,82 @@
+"""CLI entry point for the Claude PR Review agent."""
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
+        description="Claude Code PR Review Agent - Analyze PRs and generate structured review comments"
+    )
+    parser.add_argument(
+        "--pr",
+        required=True,
+        help="URL of the GitHub PR to review (e.g., https://github.com/owner/repo/pull/123)",
+    )
+    parser.add_argument(
+        "--diff",
+        help="Path to a local diff file (optional, will fetch from PR URL if not provided)",
+    )
+    parser.add_argument(
+        "--output",
+        "-o",
+        help="Output file for the review (default: stdout)",
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
+    # Validate API key
+    api_key = os.environ.get("ANTHROPIC_API_KEY")
+    if not api_key:
+        print("Error: ANTHROPIC_API_KEY environment variable is required", file=sys.stderr)
+        sys.exit(1)
+
+    # Initialize reviewer
+    reviewer = ClaudeReviewer(api_key=api_key, model=args.model)
+
+    # Get diff content
+    if args.diff:
+        with open(args.diff, "r") as f:
+            diff_content = f.read()
+    else:
+        diff_content = reviewer.fetch_pr_diff(args.pr)
+
+    if not diff_content:
+        print("Error: Could not retrieve PR diff", file=sys.stderr)
+        sys.exit(1)
+
+    # Generate review
+    review = reviewer.review_pr(args.pr, diff_content)
+
+    # Output review
+    if args.output:
+        with open(args.output, "w") as f:
+            f.write(review)
+        print(f"Review written to {args.output}")
+    else:
+        print(review)
+
+    # Post comment if requested
+    if args.post_comment:
+        success = reviewer.post_pr_comment(args.pr, review)
+        if success:
+            print("Review posted as PR comment")
+        else:
+            print("Warning: Failed to post PR comment", file=sys.stderr)
+
+
+if __name__ == "__main__":
+    main()
+--- /dev/null
+++ b/claude_review/reviewer.py
@@ -0,0 +1,224 @@
+"""Core PR review logic using Claude API."""
+
+import json
+import os
+import re
+from typing import Optional
+
+import requests
+
+
+class ClaudeReviewer:
+    """Claude Code PR Review Agent."""
+
+    def __init__(self, api_key: str, model: str = "claude-sonnet-4-20250514"):
+        self.api_key = api_key
+        self.model = model
+        self.api_url = "https://api.anthropic.com/v1/messages"
+
+    def _call_claude(self, prompt: str, max_tokens: int = 4000) -> str:
+        """Make a request to the Claude API."""
+        headers = {
+            "x-api-key": self.api_key,
+            "Content-Type": "application/json",
+            "anthropic-version": "2023-06-01",
+        }
+
+        payload = {
+            "model": self.model,
+            "max_tokens": max_tokens,
+            "messages": [
+                {
+                    "role": "user",
+                    "content": prompt,
+                }
+            ],
+        }
+
+        response = requests.post(self.api_url, headers=headers, json=payload, timeout=120)
+        response.raise_for_status()
+
+        data = response.json()
+        return data["content"][0]["text"]
+
+    def fetch_pr_diff(self, pr_url: str) -> str:
+        """Fetch the diff for a GitHub PR."""
+        # Convert PR URL to diff URL
+        diff_url = pr_url.replace("github.com", "github.com/raw") + ".diff"
+        if not diff_url.endswith(".diff"):
+           