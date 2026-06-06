 ```diff
--- /dev/null
+++ b/.github/workflows/claude-review.yml
@@ -0,0 +1,35 @@
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
+          pip install -e .
+
+      - name: Run Claude PR Review
+        env:
+          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
+          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
+          PR_URL: ${{ github.event.pull_request.html_url }}
+        run: |
+          claude-review --pr "$PR_URL" --post-comment
+--- /dev/null
+++ b/claude_review/__init__.py
@@ -0,0 +1,5 @@
+"""Claude Code PR Review Agent."""
+
+__version__ = "0.1.0"
+
+from .reviewer import ClaudePRReviewer
+--- /dev/null
+++ b/claude_review/__main__.py
@@ -0,0 +1,6 @@
+"""Entry point for the claude-review CLI."""
+
+from .cli import main
+
+if __name__ == "__main__":
+    main()
+--- /dev/null
+++ b/claude_review/cli.py
@@ -0,0 +1,68 @@
+"""Command-line interface for the Claude PR Review agent."""
+
+import argparse
+import os
+import sys
+
+from .reviewer import ClaudePRReviewer
+
+
+def main():
+    """Main entry point for the CLI."""
+    parser = argparse.ArgumentParser(
+        description="Claude Code PR Review Agent - Analyze PRs and generate structured review comments.",
+        formatter_class=argparse.RawDescriptionHelpFormatter,
+        epilog="""
+Examples:
+  claude-review --pr https://github.com/owner/repo/pull/123
+  claude-review --pr https://github.com/owner/repo/pull/123 --post-comment
+  claude-review --pr https://github.com/owner/repo/pull/123 --output review.md
+        """,
+    )
+
+    parser.add_argument(
+        "--pr",
+        required=True,
+        help="URL of the GitHub PR to review (e.g., https://github.com/owner/repo/pull/123)",
+    )
+
+    parser.add_argument(
+        "--post-comment",
+        action="store_true",
+        help="Post the review as a comment on the PR (requires GITHUB_TOKEN env var)",
+    )
+
+    parser.add_argument(
+        "--output",
+        "-o",
+        help="Write the review to a file instead of stdout",
+    )
+
+    parser.add_argument(
+        "--model",
+        default="claude-sonnet-4-20250514",
+        help="Claude model to use (default: claude-sonnet-4-20250514)",
+    )
+
+    args = parser.parse_args()
+
+    # Validate API key
+    if not os.environ.get("ANTHROPIC_API_KEY"):
+        print("Error: ANTHROPIC_API_KEY environment variable is required.", file=sys.stderr)
+        sys.exit(1)
+
+    reviewer = ClaudePRReviewer(model=args.model)
+
+    try:
+        review = reviewer.review_pr(args.pr, post_comment=args.post_comment)
+
+        if args.output:
+            with open(args.output, "w") as f:
+                f.write(review)
+            print(f"Review written to {args.output}")
+        else:
+            print(review)
+
+    except Exception as e:
+        print(f"Error: {e}", file=sys.stderr)
+        sys.exit(1)
+--- /dev/null
+++ b/claude_review/reviewer.py
@@ -0,0 +1,283 @@
+"""Core PR review logic using Claude Code."""
+
+import json
+import os
+import re
+import sys
+from dataclasses import dataclass
+from typing import List, Optional
+
+import requests
+
+
+@dataclass
+class FileChange:
+    """Represents a changed file in a PR."""
+    filename: str
+    status: str  # added, removed, modified
+    additions: int
+    deletions: int
+    patch: Optional[str]
+
+
+@dataclass
+class PRInfo:
+    """Information about a pull request."""
+    owner: str
+    repo: str
+    pr_number: int
+    title: str
+    description: str
+    author: str
+    branch: str
+    base_branch: str
+
+
+class ClaudePRReviewer:
+    """Reviews GitHub PRs using Claude and generates structured Markdown output."""
+
+    def __init__(self, model: str = "claude-sonnet-4-20250514"):
+        self.model = model
+        self.api_key = os.environ.get("ANTHROPIC_API_KEY")
+        self.github_token = os.environ.get("GITHUB_TOKEN")
+        self.api_base = "https://api.anthropic.com/v1/messages"
+
+    def _call_claude(self, prompt: str, max_tokens: int = 4000) -> str:
+        """Call the Claude API with the given prompt."""
+        headers = {
+            "x-api-key": self.api_key,
+            "anthropic-version": "2023-06-01",
+            "Content-Type": "application/json",
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
+        response = requests.post(self.api_base, headers=headers, json=payload, timeout=120)
+        response.raise_for_status()
+
+        data = response.json()
+        return data["content"][0]["text"]
+
+    def _parse_pr_url(self, pr_url: str) -> PRInfo:
+        """Parse a GitHub PR URL to extract owner, repo, and PR number."""
+        pattern = r"github\.com/([^/]+)/([^/]+)/pull/(\d+)"
+        match = re.search(pattern, pr_url)
+
+