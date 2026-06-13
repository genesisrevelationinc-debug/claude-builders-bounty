 ```diff
--- /dev/null
+++ b/claude-review
@@ -0,0 +1,3 @@
+#!/usr/bin/env bash
+set -euo pipefail
+exec python3 -m claude_review.cli "$@"
--- /dev/null
+++ b/claude_review/__init__.py
@@ -0,0 +1,5 @@
+"""Claude Code PR Review Agent - Structured Markdown review comments."""
+
+__version__ = "0.1.0"
+__author__ = "Claude Builders Bounty"
+__license__ = "MIT"
--- /dev/null
+++ b/claude_review/cli.py
@@ -0,0 +1,82 @@
+#!/usr/bin/env python3
+"""CLI entry point for the Claude Code PR review agent."""
+
+import argparse
+import sys
+import os
+
+from .reviewer import review_pr
+from .github_client import GitHubClient, parse_pr_url
+
+
+def main() -> int:
+    parser = argparse.ArgumentParser(
+        description="Claude Code PR Review Agent - Generate structured Markdown review comments.",
+        formatter_class=argparse.RawDescriptionHelpFormatter,
+        epilog="""
+Examples:
+  claude-review --pr https://github.com/owner/repo/pull/123
+  claude-review --pr https://github.com/owner/repo/pull/123 --output review.md
+  GITHUB_TOKEN=ghp_xxx claude-review --pr https://github.com/owner/repo/pull/123
+        """,
+    )
+    parser.add_argument(
+        "--pr",
+        required=True,
+        help="GitHub PR URL to review (e.g., https://github.com/owner/repo/pull/123)",
+    )
+    parser.add_argument(
+        "--output",
+        "-o",
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
+    # Validate PR URL
+    pr_info = parse_pr_url(args.pr)
+    if not pr_info:
+        print(f"Error: Invalid PR URL: {args.pr}", file=sys.stderr)
+        print("Expected format: https://github.com/owner/repo/pull/123", file=sys.stderr)
+        return 1
+
+    # Check for API keys
+    if not os.environ.get("ANTHROPIC_API_KEY"):
+        print("Error: ANTHROPIC_API_KEY environment variable is required", file=sys.stderr)
+        return 1
+
+    if args.post_comment and not os.environ.get("GITHUB_TOKEN"):
+        print("Error: GITHUB_TOKEN environment variable is required for --post-comment", file=sys.stderr)
+        return 1
+
+    # Run the review
+    try:
+        review = review_pr(args.pr, model=args.model, post_comment=args.post_comment)
+    except Exception as e:
+        print(f"Error: {e}", file=sys.stderr)
+        return 1
+
+    # Output
+    if args.output:
+        with open(args.output, "w") as f:
+            f.write(review)
+        print(f"Review written to {args.output}")
+    else:
+        print(review)
+
+    return 0
+
+
+if __name__ == "__main__':
+    sys.exit(main())
--- /dev/null
+++ b/claude_review/github_client.py
@@ -0,0 +1,111 @@
+"""GitHub API client for fetching PR diffs and posting comments."""
+
+import re
+import os
+import json
+from typing import Optional, Tuple
+from urllib.request import Request, urlopen
+from urllib.error import HTTPError
+
+
+def parse_pr_url(url: str) -> Optional[Tuple[str, str, int]]:
+    """Parse a GitHub PR URL into (owner, repo, pr_number).
+    
+    Returns None if the URL is invalid.
+    """
+    patterns = [
+        r"github\.com/([^/]+)/([^/]+)/pull/(\d+)",
+        r"github\.com/([^/]+)/([^/]+)/pulls/(\d+)",
+    ]
+    for pattern in patterns:
+        match = re.search(pattern, url)
+        if match:
+            owner, repo, pr_number = match.groups()
+            return (owner, repo, int(pr_number))
+    return None
+
+
+class GitHubClient:
+    """Simple GitHub API client for PR operations."""
+
+    def __init__(self, token: Optional[str] = None):
+        self.token = token or os.environ.get("GITHUB_TOKEN")
+        self.api_base = "https://api.github.com"
+
+    def _headers(self) -> dict:
+        headers = {
+            "Accept": "application/vnd.github.v3+json",
+            "User-Agent": "claude-review/0.1.0",
+        }
+        if self.token:
+            headers["Authorization"] = f"token {self.token}"
+        return headers
+
+    def get_pr_diff(self, owner: str, repo: str, pr_number: int) -> str:
+        """Fetch the diff of a pull request."""
+        url = f"https://github.com/{owner}/{repo}/pull/{pr_number}.diff"
+        req = Request(url, headers=self._headers())
+        
+        try:
+            with urlopen(req) as response:
+                return response.read().decode("utf-8")
+        except HTTPError as e:
+            if e.code == 404:
+                raise ValueError(f"PR not found or not accessible: {owner}/{repo}#{pr_number}")
+            elif e.code == 401:
+                raise ValueError("Authentication failed. Check your GITHUB_TOKEN.")
+            raise
+
+    def get_pr_info(self, owner: str, repo: str, pr_number: int) -> dict:
+        """Fetch PR metadata."""
+        url = f"{self.api_base}/repos/{owner}/{repo}/pulls/{pr_number}"
+        req = Request(url, headers=self._headers())
+        
+        try:
+            with urlopen(req) as response:
+                return json.loads(response.read().decode("utf-8"))
+        except HTTPError as e:
+            if e.code == 404:
+                raise ValueError(f"PR not found: {owner}/{repo}#{pr_number}")
+            raise
+
+    def post_comment