 ```diff
--- /dev/null
+++ b/.github/workflows/claude-review.yml
@@ -0,0 +1,32 @@
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
+      - name: Run Claude Review
+        env:
+          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
+          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
+        run: claude-review --pr "${{ github.event.pull_request.html_url }}" --post-comment
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
@@ -0,0 +1,6 @@
+"""Entry point for running claude-review as a module."""
+
+from .cli import main
+
+if __name__ == "__main__":
+    main()
--- /dev/null
+++ b/claude_review/cli.py
@@ -0,0 +1,72 @@
+"""Command-line interface for the Claude PR Review agent."""
+
+import argparse
+import os
+import sys
+
+from .reviewer import ClaudeReviewer
+
+
+def main() -> None:
+    """Run the CLI."""
+    parser = argparse.ArgumentParser(
+        description="Claude Code PR Review Agent — structured Markdown review comments"
+    )
+    parser.add_argument(
+        "--pr",
+        required=True,
+        help="GitHub PR URL (e.g., https://github.com/owner/repo/pull/123)",
+    )
+    parser.add_argument(
+        "--output",
+        "-o",
+        default=None,
+        help="Write review to file instead of stdout",
+    )
+    parser.add_argument(
+        "--post-comment",
+        action="store_true",
+        help="Post the review as a comment on the PR (requires GITHUB_TOKEN)",
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
+        print(
+            "Error: ANTHROPIC_API_KEY environment variable is required.",
+            file=sys.stderr,
+        )
+        sys.exit(1)
+
+    github_token = os.environ.get("GITHUB_TOKEN")
+    if args.post_comment and not github_token:
+        print(
+            "Error: GITHUB_TOKEN environment variable is required for --post-comment.",
+            file=sys.stderr,
+        )
+        sys.exit(1)
+
+    reviewer = ClaudeReviewer(api_key=api_key, model=args.model, github_token=github_token)
+
+    try:
+        review = reviewer.review_pr(args.pr, post_comment=args.post_comment)
+    except Exception as exc:  # noqa: BLE001
+        print(f"Error: {exc}", file=sys.stderr)
+        sys.exit(1)
+
+    if args.output:
+        with open(args.output, "w", encoding="utf-8") as f:
+            f.write(review)
+    else:
+        print(review)
+
+
+if __name__ == "__main__":
+    main()
--- /dev/null
+++ b/claude_review/reviewer.py
@@ -0,0 +1,260 @@
+"""Core PR review logic using Claude Code."""
+
+import json
+import os
+import re
+import urllib.request
+from dataclasses import dataclass
+from typing import Optional
+
+
+@dataclass
+class PRInfo:
+    """Parsed PR information."""
+
+    owner: str
+    repo: str
+    number: int
+
+
+class ClaudeReviewer:
+    """Reviews GitHub PRs using Claude and produces structured Markdown output."""
+
+    def __init__(
+        self,
+        api_key: str,
+        model: str = "claude-sonnet-4-20250514",
+        github_token: Optional[str] = None,
+    ) -> None:
+        self.api_key = api_key
+        self.model = model
+        self.github_token = github_token or os.environ.get("GITHUB_TOKEN", "")
+        self.api_base = "https://api.anthropic.com/v1/messages"
+
+    def _parse_pr_url(self, pr_url: str) -> PRInfo:
+        """Extract owner, repo, and PR number from a GitHub PR URL."""
+        patterns = [
+            r"github\.com/([^/]+)/([^/]+)/pull/(\d+)",
+            r"github\.com/([^/]+)/([^/]+)/pulls/(\d+)",
+        ]
+        for pattern in patterns:
+            match = re.search(pattern, pr_url)
+            if match:
+                return PRInfo(
+                    owner=match.group(1),
+                    repo=match.group(2),
+                    number=int(match.group(3)),
+                )
+        raise ValueError(f"Could not parse PR URL: {pr_url}")
+
+    def _github_api_request(self, endpoint: str) -> dict:
+        """Make an authenticated GitHub API request."""
+        url = f"https://api.github.com{endpoint}"
+        headers = {
+            "Accept": "application/vnd.github.v3+json",
+            "User-Agent": "claude-review/0.1.0",
+        }
+        if self.github_token:
+            headers["Authorization"] = f"token {self.github_token}"
+
+        req = urllib.request.Request(url, headers=headers)  # noqa: S310
+        with urllib.request.urlopen(req) as response:  # noqa: S310
+            return json.loads(response.read().decode("utf-8"))
+
+    def _fetch_pr_diff(self, pr_info: PRInfo) -> str:
+        """Fetch the PR diff from GitHub."""
+        url = f"https://github.com