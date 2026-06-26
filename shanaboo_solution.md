 ```diff
--- /dev/null
+++ b/.github/workflows/claude-review.yml
@@ -0,0 +1,36 @@
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
+        run: |
+          claude-review --pr "${{ github.event.pull_request.html_url }}" \
+            --github-token "$GITHUB_TOKEN" \
+            --post-comment
+--- /dev/null
+++ b/claude_review/__init__.py
@@ -0,0 +1,5 @@
+"""Claude Code PR Review Agent."""
+
+__version__ = "0.1.0"
+
+from .reviewer import PRReviewer
--- /dev/null
+++ b/claude_review/__main__.py
@@ -0,0 +1,6 @@
+"""Entry point for running claude-review as a module."""
+
+from .cli import main
+
+if __name__ == "__main__":
+    main()
--- /dev/null
+++ b/claude_review/cli.py
@@ -0,0 +1,82 @@
+"""Command-line interface for the Claude PR Review agent."""
+
+import argparse
+import os
+import sys
+
+from .reviewer import PRReviewer
+
+
+def main() -> None:
+    """Run the CLI."""
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
+    parser.add_argument(
+        "--pr",
+        required=True,
+        help="URL of the GitHub PR to review (e.g., https://github.com/owner/repo/pull/123)",
+    )
+    parser.add_argument(
+        "--github-token",
+        default=os.environ.get("GITHUB_TOKEN"),
+        help="GitHub personal access token (defaults to GITHUB_TOKEN env var)",
+    )
+    parser.add_argument(
+        "--anthropic-api-key",
+        default=os.environ.get("ANTHROPIC_API_KEY"),
+        help="Anthropic API key (defaults to ANTHROPIC_API_KEY env var)",
+    )
+    parser.add_argument(
+        "--post-comment",
+        action="store_true",
+        help="Post the review as a comment on the PR",
+    )
+    parser.add_argument(
+        "--output",
+        "-o",
+        help="Write the review to a file instead of stdout",
+    )
+    parser.add_argument(
+        "--model",
+        default="claude-sonnet-4-20250514",
+        help="Claude model to use (default: claude-sonnet-4-20250514)",
+    )
+
+    args = parser.parse_args()
+
+    if not args.github_token:
+        print("Error: GitHub token required. Set GITHUB_TOKEN env var or use --github-token.", file=sys.stderr)
+        sys.exit(1)
+
+    if not args.anthropic_api_key:
+        print("Error: Anthropic API key required. Set ANTHROPIC_API_KEY env var or use --anthropic-api-key.", file=sys.stderr)
+        sys.exit(1)
+
+    reviewer = PRReviewer(
+        github_token=args.github_token,
+        anthropic_api_key=args.anthropic_api_key,
+        model=args.model,
+    )
+
+    review = reviewer.review_pr(args.pr, post_comment=args.post_comment)
+
+    if args.output:
+        with open(args.output, "w") as f:
+            f.write(review)
+        print(f"Review written to {args.output}")
+    else:
+        print(review)
+
+
+if __name__ == "__main__":
+    main()
--- /dev/null
+++ b/claude_review/reviewer.py
@@ -0,0 +1,283 @@
+"""Core PR review logic using Claude Code."""
+
+import json
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
+class PRInfo:
+    """Information about a GitHub PR."""
+
+    owner: str
+    repo: str
+    number: int
+    title: str
+    description: str
+    author: str
+    branch: str
+    base_branch: str
+
+
+class PRReviewer:
+    """Reviews GitHub PRs using Claude and generates structured Markdown output."""
+
+    def __init__(
+        self,
+        github_token: str,
+        anthropic_api_key: str,
+        model: str = "claude-sonnet-4-20250514",
+    ):
+        self.github_token = github_token
+        self.anthropic_api_key = anthropic_api_key
+        self.model = model
+        self.github_headers = {
+            "Authorization": f"token {github_token}",
+            "Accept": "application/vnd.github.v3+json",
+        }
+        self.anthropic_headers = {
+            "x-api-key": anthropic_api_key,
+            "Content-Type": "application/json",
+            "anthropic-version": "2023-06-01",
+        }
+
+    def _parse_pr_url(self, pr_url: str) -> tuple[str, str, int]:
+        """Extract owner, repo, and PR number from a GitHub PR URL."""
+        patterns = [
+            r"github\.com/([^/]+)/([^/]+)/pull/(\d+)",
+            r"github\.com/([^/]+)/([^/]+)/pulls/(\d+)",
+        ]
+        for pattern in patterns:
+            match = re.search