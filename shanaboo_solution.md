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
+    steps:
+      - name: Checkout code
+        uses: actions/checkout@v4
+
+      - name: Set up Python
+        uses: actions/setup-python@v5
+        with:
+          python-version: '3.11'
+
+      - name: Install dependencies
+        run: |
+          pip install requests
+
+      - name: Run Claude PR Review
+        env:
+          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
+          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
+          PR_NUMBER: ${{ github.event.pull_request.number }}
+          REPO: ${{ github.repository }}
+        run: |
+          python .github/scripts/claude_review.py
+
+      - name: Post review comment
+        env:
+          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
+          PR_NUMBER: ${{ github.event.pull_request.number }}
+          REPO: ${{ github.repository }}
+        run: |
+          REVIEW=$(cat review_output.md)
+          gh api repos/$REPO/issues/$PR_NUMBER/comments \
+            -f body="$REVIEW"
+        shell: bash
--- /dev/null
+++ b.claude-review
@@ -0,0 +1,5 @@
+[tool.poetry]
+name = "claude-review"
+version = "0.1.0"
+description = "Claude Code PR reviewer with structured Markdown output"
+authors = ["Claude Builders Bounty"]
--- /dev/null
+++ b.claude-review
@@ -0,0 +1,2 @@
+[tool.poetry.dependencies]
+python = "^3.11"
--- /dev/null
+++ b.claude-review
@@ -0,0 +1,2 @@
+[build-system]
+requires = ["poetry-core"]
--- /dev/null
+++ b.claude-review
@@ -0,0 +1,2 @@
+build-backend = "poetry.core.masonry.api"
+--- /dev/null
+++ b.claude-review
@@ -0,0 +1,2 @@
+[tool.poetry.scripts]
+claude-review = "claude_review.cli:main"
--- /dev/null
+++ b.claude-review
@@ -0,0 +1,2 @@
+[tool.poetry.packages]
+include = [{include = "claude_review"}]
--- /dev/null
+++ b/claude_review/__init__.py
@@ -0,0 +1,3 @@
+"""Claude PR Reviewer - Structured Markdown code review agent."""
+
+__version__ = "0.1.0"
--- /dev/null
+++ b/claude_review/cli.py
@@ -0,0 +1,67 @@
+#!/usr/bin/env python3
+"""CLI entry point for claude-review."""
+
+import argparse
+import sys
+import os
+
+from .reviewer import ClaudeReviewer
+from .github_client import GitHubClient
+
+
+def parse_pr_url(url: str) -> tuple[str, str, int]:
+    """Parse a GitHub PR URL into (owner, repo, pr_number)."""
+    # Handle formats like:
+    # https://github.com/owner/repo/pull/123
+    # https://github.com/owner/repo/pull/123/files
+    parts = url.rstrip('/').split('/')
+    if 'github.com' not in url:
+        raise ValueError(f"Invalid GitHub URL: {url}")
+    
+    # Find the position of 'github.com'
+    idx = parts.index('github.com')
+    owner = parts[idx + 1]
+    repo = parts[idx + 2]
+    pr_number = int(parts[idx + 4].split('?')[0].split('#')[0])
+    return owner, repo, pr_number
+
+
+def main():
+    parser = argparse.ArgumentParser(
+        description="Claude Code PR Reviewer - Analyze PRs with structured Markdown output"
+    )
+    parser.add_argument(
+        "--pr", 
+        required=True, 
+        help="GitHub PR URL to review"
+    )
+    parser.add_argument(
+        "--api-key",
+        help="Anthropic API key (or set ANTHROPIC_API_KEY env var)"
+    )
+    parser.add_argument(
+        "--github-token",
+        help="GitHub token (or set GITHUB_TOKEN env var)"
+    )
+    
+    args = parser.parse_args()
+    
+    api_key = args.api_key or os.environ.get("ANTHROPIC_API_KEY")
+    if not api_key:
+        print("Error: ANTHROPIC_API_KEY required", file=sys.stderr)
+        sys.exit(1)
+    
+    github_token = args.github_token or os.environ.get("GITHUB_TOKEN")
+    
+    owner, repo, pr_number = parse_pr_url(args.pr)
+    
+    github = GitHubClient(token=github_token)
+    reviewer = ClaudeReviewer(api_key=api_key)
+    
+    diff = github.get_pr_diff(owner, repo, pr_number)
+    review = reviewer.review(diff, owner=owner, repo=repo, pr_number=pr_number)
+    
+    print(review)
+
+
+if __name__ == "__main__':
+    main()
--- /dev/null
+++ b/claude_review/github_client.py
@@ -0,0 +1,50 @@
+"""GitHub API client for fetching PR diffs."""
+
+import urllib.request
+import urllib.error
+from typing import Optional
+
+
+class GitHubClient:
+    """Simple GitHub API client for PR operations."""
+    
+    def __init__(self, token: Optional[str] = None):
+        self.token = token
+        self.base_url = "https://api.github.com"
+    
+    def _get_headers(self) -> dict:
+        """Build request headers with optional auth."""
+        headers = {
+            "Accept": "application/vnd.github.v3.diff",
+            "User-Agent": "claude-review/0.1.0"
+        }
+        if self.token:
+            headers["Authorization"] = f"token {self.token}"
+        return headers
+    
+    def get_pr_diff(self, owner: str, repo: str, pr_number: int) -> str:
+        """Fetch the diff for a pull request."""
+        url = f"{self.base_url}/repos/{owner}/{repo}/pulls/{pr_number}"
+        headers = self._get_headers()
+        
+        req = urllib.request.Request(url, headers