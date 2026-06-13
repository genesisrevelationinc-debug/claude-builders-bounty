 ```diff
--- /dev/null
+++ b/.github/workflows/pr-review.yml
@@ -0,0 +1,38 @@
+name: PR Review
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
+      - name: Run PR Review
+        env:
+          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
+          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
+        run: |
+          claude-review --pr "${{ github.event.pull_request.html_url }}" --output review.md
+
+      - name: Post Review Comment
+        uses: marocchino redirects to actions/github-script@v7
+        with:
+          script: |
+            const fs = require('fs');
+            const review = fs.readFileSync('review.md', 'utf8');
+            github.rest.issues.createComment({
+              issue_number: context.issue.number,
+              owner: context.repo.owner,
+              repo: context.repo.repo,
+              body: review
+            });
+--- /dev/null
+++ b/claude_review/__init__.py
@@ -0,0 +1,5 @@
+"""Claude Code PR Review Agent."""
+
+__version__ = "0.1.0"
+
+from .reviewer import review_pr, generate_review_comment
+--- /dev/null
+++ b/claude_review/__main__.py
@@ -0,0 +1,4 @@
+"""Entry point for running claude-review as a module."""
+from .cli import main
+
+main()
+--- /dev/null
+++	/claude_review/cli.py
@@ -0,0 +1,82 @@
+"""CLI for the Claude Code PR Review Agent."""
+import argparse
+import os
+import sys
+
+from .reviewer import review_pr
+
+
+def main():
+    parser = argparse.ArgumentParser(
+        description="Claude Code PR Review Agent - Analyze PRs and generate structured review comments"
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
+        help="Output file path (default: print to stdout)",
+    )
+    parser.add_argument(
+        "--api-key",
+        default=None,
+        help="Anthropic API key (default: ANTHROPIC_API_KEY env var)",
+    )
+    parser.add_argument(
+        "--github-token",
+        default=None,
+        help="GitHub token (default: GITHUB_TOKEN env var)",
+    )
+    parser.add_argument(
+        "--model",
+        default="claude-sonnet-4-20250514",
+        help="Claude model to use (default: claude-sonnet-4-20250514)",
+    )
+
radiation
+    args = parser.parse_args()
+
+    api_key = args.api_key or os.environ.get("ANTHROPIC_API_KEY")
+    if not api_key:
+        print(
+            "Error: Anthropic API key required. Set ANTHROPIC_API_KEY or use --api-key.",
+            file=sys.stderr,
+        )
+        sys.exit(1)
+
+    github_token = args.github_token or os.environ.get("GITHUB_TOKEN")
+    if not github_token:
+        print(
+            "Error: GitHub token required. Set GITHUB_TOKEN or use --github-token.",
+            file=sys.stderr,
+        )
+        sys.exit(1)
+
+    try:
+        review = review_pr(
+            pr_url=args.pr,
+            api_key=api_key,
+            github_token=github_token,
+            model=args.model,
+        )
+    except Exception as e:
+        print(f"Error: {e}", file=sys.stderr)
+        sys.exit(1)
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
+--- /dev/null
+++ b/claude_review/reviewer.py
@@ -0,0 +1,196 @@
+"""Core PR review logic using Claude Code."""
+import os
+import re
+import sys
+from typing import Optional
+
+import requests
+
+
+def parse_pr_url(pr_url: str) -> tuple[str, str, int]:
+    """Parse a GitHub PR URL into (owner, repo, pr_number)."""
+    match = re.match(r"https?://github\.com/([^/]+)/([^/]+)/pull/(\d+)", pr_url)
+    if not match:
+        raise ValueError(f"Invalid GitHub PR URL: {pr_url}")
+    owner, repo, pr_number = match.groups()
+    return owner, repo, int(pr_number)
+
+
+def fetch_pr_diff(owner: str, repo: str, pr_number: int, github_token: str) -> str:
+    """Fetch the diff of a PR from GitHub API."""
+    headers = {
+        "Authorization": f"token {github_token}",
+        "Accept": "application/vnd.github.v3.diff",
+    }
+    url = f"https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}"
+    response = requests.get(url, headers=headers)
+    response.raise_for_status()
+    return response.text
+
+
+def fetch_pr_info(owner: str, repo: str, pr_number: int, github_token: str) -> dict:
+    """Fetch PR metadata from GitHub API."""
+    headers = {
+        "Authorization": f"token {github_token}",
+        "Accept": "application/vnd.github.v3+json",
+    }
+    url = f"https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}"
+    response = requests.get(url, headers=headers)
+    response.raise_for_status()
+    return response.json()
+
+
+def call_claude_for_review(
+    diff: str,
+    pr_title: str,
+    pr_body: str,
+   