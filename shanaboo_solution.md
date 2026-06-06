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
+          pip install claude-review
+
+      - name: Get PR diff
+        id: get-diff
+        run: |
+          gh pr diff ${{ github.event.pull_request.number }} > pr_diff.txt
+        env:
+          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
+
+      - name: Run Claude Review
+        env:
+          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
+          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
+        run: |
+          claude-review --pr ${{ github.event.pull_request.html_url }} --diff-file pr_diff.txt --post-comment
+        working-directory: .
+
--- /dev/null
+++ b/claude_review/__init__.py
@@ -0,0 +1,5 @@
+"""Claude Code PR Review Agent."""
+
+__version__ = "0.1.0"
+
+from .reviewer import ClaudeReviewer
--- /dev/null
+++ b/claude_review/__main__.py
@@ -0,0 +1,4 @@
+from .cli import main
+
+if __name__ == "__main__":
+    main()
--- /dev/null
+++ b/claude_review/cli.py
@@ -0,0 +1,68 @@
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
+        description="Claude Code PR Review Agent - Analyze PRs and generate structured review comments."
+    )
+    parser.add_argument(
+        "--pr",
+        required=True,
+        help="URL of the GitHub PR to review (e.g., https://github.com/owner/repo/pull/123)",
+    )
+    parser.add_argument(
+        "--diff-file",
+        help="Path to a file containing the PR diff (optional, will fetch from GitHub if not provided)",
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
+    api_key = os.environ.get("ANTHROPIC_API_KEY")
+    if not api_key:
+        print("Error: ANTHROPIC_API_KEY environment variable is required.", file=sys.stderr)
+        sys.exit(1)
+
+    reviewer = ClaudeReviewer(api_key=api_key, model=args.model)
+
+    diff_text = None
+    if args.diff_file:
+        with open(args.diff_file, "r") as f:
+            diff_text = f.read()
+
+    try:
+        review = reviewer.review_pr(args.pr, diff_text=diff_text)
+    except Exception as e:
+        print(f"Error generating review: {e}", file=sys.stderr)
+        sys.exit(1)
+
+    if args.output:
+        with open(args.output, "w") as f:
+            f.write(review)
+        print(f"Review saved to {args.output}")
+    else:
+        print(review)
+
+    if args.post_comment:
+        reviewer.post_comment(args.pr, review)
--- /dev/null
+++ b/claude_review/reviewer.py
@@ -0,0 +1,197 @@
+"""Core PR review logic using Claude Code."""
+
+import os
+import re
+import sys
+from dataclasses import dataclass
+from typing import Optional
+
+import requests
+
+
+@dataclass
+class ReviewResult:
+    """Structured PR review result."""
+
+    summary: str
+    risks: list[str]
+    suggestions: list[str]
+    confidence: str
+    raw_markdown: str
+
+
+class ClaudeReviewer:
+    """Claude Code-based PR reviewer."""
+
+    ANTHROPIC_API_URL = "https://api.anthropic.com/v1/messages"
+
+    def __init__(self, api_key: str, model: str = "claude-sonnet-4-20250514"):
+        self.api_key = api_key
+        self.model = model
+        self.headers = {
+            "x-api-key": api_key,
+            "anthropic-version": "2023-06-01",
+            "Content-Type": "application/json",
+        }
+
+    def _call_claude(self, prompt: str, max_tokens: int = 4096) -> str:
+        """Call the Anthropic Claude API with the given prompt."""
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
+        response = requests.post(
+            self.ANTHROPIC_API_URL,
+            headers=self.headers,
+            json=payload,
+            timeout=120,
+        )
+        response.raise_for_status()
+        data = response.json()
+
+        # Extract text content from the response
+        content = data.get("content", [])
+        if content and isinstance(content, list):
+            text_parts = []
+            for item in content:
+                if isinstance(item, dict) and item.get("type") == "text":
+                    text_parts.append(item.get("text", ""))
+            return "".join(text_parts)
+
+        # Fallback for older API response format
+        return data.get("content", "") or data.get("completion", "")
+
+    def _fetch_diff_from_github(self, pr_url: str) -> str