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
+        id: get-diff
+        run: |
+          curl -s -H "Authorization: token ${{ secrets.GITHUB_TOKEN }}" \
+            "${{ github.event.pull_request.diff_url }}" > pr.diff
+          echo "diff_path=pr.diff" >> $GITHUB_OUTPUT
+
+      - name: Run Claude Review
+        env:
+          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
+          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
+          PR_URL: ${{ github.event.pull_request.html_url }}
+        run: |
+          claude-review --pr "$PR_URL" --diff "${{ steps.get-diff.outputs.diff_path }}" --post-comment
+--- /dev/null
+++ b/claude_review/__init__.py
@@ -0,0 +1,3 @@
+"""Claude Code PR Review Agent."""
+
+__version__ = "0.1.0"
+--- /dev/null
+++ b/claude_review/cli.py
@@ -0,0 +1,76 @@
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
+        description="Claude Code PR Review Agent - Analyze PRs and post structured comments"
+    )
+    parser.add_argument(
+        "--pr",
+        required=True,
+        help="URL of the GitHub PR to review (e.g., https://github.com/owner/repo/pull/123)",
+    )
+    parser.add_argument(
+        "--diff",
+        help="Path to a local diff file. If omitted, the diff is fetched from the PR URL.",
+    )
+    parser.add_argument(
+        "--output",
+        "-o",
+        help="Write the review to a file instead of stdout.",
+    )
+    parser.add_argument(
+        "--post-comment",
+        action="store_true",
+        help="Post the review as a comment on the PR (requires GITHUB_TOKEN env var).",
+    )
+    parser.add_argument(
+        "--model",
+        default="claude-sonnet-4-20250514",
+        help="Claude model to use (default: claude-sonnet-4-20250514).",
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
+    # Load diff
+    if args.diff:
+        with open(args.diff, "r", encoding="utf-8") as f:
+            diff_text = f.read()
+    else:
+        diff_text = reviewer.fetch_pr_diff(args.pr)
+
+    if not diff_text or not diff_text.strip():
+        print("Error: Could not retrieve PR diff.", file=sys.stderr)
+        sys.exit(1)
+
+    # Generate review
+    review = reviewer.review(diff_text, pr_url=args.pr)
+
+    # Output
+    if args.output:
+        with open(args.output, "w", encoding="utf-8") as f:
+            f.write(review)
+        print(f"Review written to {args.output}")
+    else:
+        print(review)
+
+    # Post comment if requested
+    if args.post_comment:
+        reviewer.post_pr_comment(args.pr, review)
+        print("Review posted as PR comment.")
+
+
+if __name__ == "__main__":
+    main()
+--- /dev/null
+++ b/claude_review/reviewer.py
@@ -0,0 +1,195 @@
+"""Core review logic for the Claude PR Review agent."""
+
+import json
+import os
+import re
+import textwrap
+from typing import Optional
+
+import requests
+
+
+class ClaudeReviewer:
+    """Agent that reviews PR diffs using Claude and produces structured Markdown output."""
+
+    def __init__(self, api_key: str, model: str = "claude-sonnet-4-20250514"):
+        self.api_key = api_key
+        self.model = model
+        self.api_url = "https://api.anthropic.com/v1/messages"
+
+    def _call_claude(self, prompt: str, max_tokens: int = 4096) -> str:
+        headers = {
+            "x-api-key": self.api_key,
+            "anthropic-version": "2023-06-01",
+            "Content-Type": "application/json",
+        }
+        payload = {
+            "model": self.model,
+            "max_tokens": max_tokens,
+            "messages": [{"role": "user", "content": prompt}],
+        }
+        response = requests.post(self.api_url, headers=headers, json=payload, timeout=120)
+        response.raise_for_status()
+        data = response.json()
+        return data["content"][0]["text"]
+
+    def fetch_pr_diff(self, pr_url: str) -> str:
+        """Fetch the diff for a GitHub PR from its URL."""
+        # Convert PR URL to diff URL
+        diff_url = pr_url.replace("github.com", "api.github.com/repos").replace("/pull/", "/pulls/")
+        if diff_url.endswith("/"):
+            diff_url = diff_url[:-1]
+        # Add .diff suffix for raw diff
+        raw_diff_url = f"{diff_url}.diff"
+
+        headers = {}
+        token = os.environ.get("GITHUB_TOKEN")
+        if token:
+            headers["Authorization"] = f"token {token}"
+
+        response = requests.get(raw_diff_url, headers=headers, timeout=60)
+        response.raise_for_status()
+        return response.text
+
+    def _build_prompt(self, diff