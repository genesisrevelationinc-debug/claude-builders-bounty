 ```diff
--- /dev/null
+++ b/.github/workflows/claude-review.yml
@@ -0,0 +1,41 @@
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
@@ -0,0 +1,3 @@
+"""Claude Code PR Review Agent."""
+
+__version__ = "0.1.0"
--- /dev/null
+++ b/claude_review/cli.py
@@ -0,0 +1,109 @@
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
+def main() -> int:
+    """Run the CLI."""
+    parser = argparse.ArgumentParser(
+        description="Claude Code PR Review Agent - Analyze PRs and generate structured review comments."
+    )
+    parser.add_argument(
+        "--pr",
+        required=True,
+        help="URL of the GitHub PR to review (e.g., https://github.com/owner/repo/pull/123)",
+    )
+    parser.add_argument(
+        "--diff",
+        default=None,
+        help="Path to a local diff file. If omitted, the diff is fetched from the PR URL.",
+    )
+    parser.add_argument(
+        "--output",
+        "-o",
+        default=None,
+        help="Path to write the review Markdown. If omitted, prints to stdout.",
+    )
+    parser.add_argument(
+        "--post-comment",
+        action="store_true",
+        help="Post the review as a comment on the PR (requires GITHUB_TOKEN env var).",
+    )
+    parser.add_argument(
+        "--model",
+        default="claude-sonnet-4-20250514",
+        help="Anthropic model to use for review.",
+    )
+    parser.add_argument(
+        "--max-tokens",
+        type=int,
+        default=4096,
+        help="Maximum tokens for the Anthropic API response.",
+    )
+
+    args = parser.parse_args()
+
+    api_key = os.environ.get("ANTHROPIC_API_KEY")
+    if not api_key:
+        print("Error: ANTHROPIC_API_KEY environment variable is required.", file=sys.stderr)
+        return 1
+
+    # Validate PR URL format
+    if not args.pr.startswith("https://github.com/") or "/pull/" not in args.pr:
+        print(
+            "Error: PR URL must be a valid GitHub pull request URL "
+            "(e.g., https://github.com/owner/repo/pull/123)",
+            file=sys.stderr,
+        )
+        return 1
+
+    reviewer = ClaudeReviewer(
+        api_key=api_key,
+        model=args.model,
+        max_tokens=args.max_tokens,
+    )
+
+    try:
+        review = reviewer.review_pr(
+            pr_url=args.pr,
+            diff_path=args.diff,
+        )
+    except Exception as exc:  # noqa: BLE001
+        print(f"Error generating review: {exc}", file=sys.stderr)
+        return 1
+
+    if args.output:
+        with open(args.output, "w", encoding="utf-8") as f:
+            f.write(review)
+        print(f"Review written to {args.output}")
+    else:
+        print(review)
+
+    if args.post_comment:
+        github_token = os.environ.get("GITHUB_TOKEN")
+        if not github_token:
+            print("Error: GITHUB_TOKEN environment variable is required to post comment.", file=sys.stderr)
+            return 1
+        from .github_client import post_pr_comment
+
+        post_pr_comment(args.pr, review, github_token)
+
+    return 0
+
+
+if __name__ == "__main__":
+    sys.exit(main())
--- /dev/null
+++ b/claude_review/github_client.py
@@ -0,0 +1,55 @@
+"""GitHub API client for posting PR comments."""
+
+import re
+import urllib.request
+from urllib.error import HTTPError
+
+
+def extract_owner_repo_pr(pr_url: str) -> tuple[str, str, str]:
+    """Extract owner, repo, and PR number from a GitHub PR URL."""
+    match = re.match(r"https://github\.com/([^/]+)/([^/]+)/pull/(\d+)", pr_url)
+    if not match:
+        raise ValueError(f"Invalid GitHub PR URL: {pr_url}")
+    return match.group(1), match.group(2), match.group(3)
+
+
+def post_pr_comment(pr_url: str, body: str, token: str) -> None:
+    """Post a comment on a GitHub PR."""
+    owner, repo, pr_number = extract_owner_repo_pr(pr_url)
+    url = f"https://api.github.com/repos/{owner}/{repo}/issues/{pr_number}/comments"
+
+    # Escape special characters for JSON
+    import json
+
+    data = json.dumps({"body": body}).encode("utf-8")
+
+    req = urllib.request.Request(
+        url,
+        data=data,
+        headers={
+            "Authorization": f"token {token}",
+            "Accept": "application/vnd.github.v3+json",
+            "Content-Type": "application/json",
+        },
+        method="POST",
+    )
+
+    try:
+        with urllib.request.urlopen(req) as response:
+            if response.status in (201, 