 ```diff
--- /dev/null
+++ b/claude-review
@@ -0,0 +1,5 @@
+#!/usr/bin/env bash
+set -euo pipefail
+
+SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
+exec python3 "$SCRIPT_DIR/claude_review/cli.py" "$@"
--- /dev/null
+++ b/claude_review/__init__.py
@@ -0,0 +1,3 @@
+"""Claude Code PR Review Agent."""
+
+__version__ = "0.1.0"
--- /dev/null
+++ b/claude_review/cli.py
@@ -0,0 +1,120 @@
+#!/usr/bin/env python3
+"""CLI entry point for the Claude Code PR review agent."""
+
+import argparse
+import os
+import re
+import sys
+from urllib.parse import urlparse
+
+from .reviewer import review_pr
+
+
+def validate_pr_url(url: str) -> bool:
+    """Validate that the URL is a GitHub PR URL."""
+    pattern = r"^https://github\.com/[^/]+/[^/]+/pull/\d+/?$"
+    return bool(re.match(pattern, url))
+
+
+def parse_pr_url(url: str) -> tuple[str, str, int]:
+    """Parse a GitHub PR URL into (owner, repo, pr_number)."""
+    parsed = urlparse(url)
+    path_parts = parsed.path.strip("/").split("/")
+    # path: owner/repo/pull/123
+    if len(path_parts) < 4 or path_parts[2] != "pull":
+        raise ValueError(f"Invalid PR URL: {url}")
+    owner = path_parts[0]
+    repo = path_parts[1]
+    pr_number = int(path_parts[3])
+    return owner, repo, pr_number
+
+
+def main() -> None:
+    parser = argparse.ArgumentParser(
+        description="Claude Code PR Review Agent - Generate structured Markdown reviews for GitHub PRs",
+        formatter_class=argparse.RawDescriptionHelpFormatter,
+        epilog="""
+Examples:
+  claude-review --pr https://github.com/owner/repo/pull/123
+  claude-review --pr https://github.com/owner/repo/pull/123 --output review.md
+  claude-review --pr https://github.com/owner/repo/pull/123 --github-token ghp_xxx
+        """,
+    )
+    parser.add_argument(
+        "--pr",
+        required=True,
+        help="GitHub PR URL to review",
+    )
+    parser.add_argument(
+        "--output",
+        "-o",
+        help="Output file for the review (default: print to stdout)",
+    )
+    parser.add_argument(
+        "--github-token",
+        help="GitHub personal access token (or set GITHUB_TOKEN env var)",
+    )
+    parser.add_argument(
+        "--anthropic-api-key",
+        help="Anthropic API key (or set ANTHROPIC_API_KEY env var)",
+    )
+    parser.add_argument(
+        "--model",
+        default="claude-sonnet-4-20250514",
+        help="Claude model to use (default: claude-sonnet-4-20250514)",
+    )
+    parser.add_argument(
+        "--post-comment",
+        action="store_true",
+        help="Post the review as a comment on the PR (requires --github-token)",
+    )
+
+    args = parser.parse_args()
+
+    # Validate PR URL
+    if not validate_pr_url(args.pr):
+        print(f"Error: Invalid GitHub PR URL: {args.pr}", file=sys.stderr)
+        print("Expected format: https://github.com/owner/repo/pull/123", file=sys.stderr)
+        sys.exit(1)
+
+    # Parse PR URL
+    try:
+        owner, repo, pr_number = parse_pr_url(args.pr)
+    except ValueError as e:
+        print(f"Error: {e}", file=sys.stderr)
+        sys.exit(1)
+
+    # Get API keys
+    github_token = args.github_token or os.environ.get("GITHUB_TOKEN")
+    anthropic_api_key = args.anthropic_api_key or os.environ.get("ANTHROPIC_API_KEY")
+
+    if not github_token:
+        print("Error: GitHub token required. Use --github-token or set GITHUB_TOKEN env var.", file=sys.stderr)
+        sys.exit(1)
+
+    if not anthropic_api_key:
+        print("Error: Anthropic API key required. Use --anthropic-api-key or set ANTHROPIC_API_KEY env var.", file=sys.stderr)
+        sys.exit(1)
+
+    # Run the review
+    review = review_pr(
+        owner=owner,
+        repo=repo,
+        pr_number=pr_number,
+        github_token=github_token,
+        anthropic_api_key=anthropic_api_key,
+        model=args.model,
+        pr_url=args.pr,
+        post_comment=args.post_comment,
+    )
+
+    if args.output:
+        with open(args.output, "w") as f:
+            f.write(review)
+        print(f"Review saved to {args.output}")
+    else:
+        print(review)
+
+
+if __name__ == "__main__":
+    main()
--- /dev/null
+++ b/claude_review/reviewer.py
@@ -0,0 +1,280 @@
+"""Core PR review logic using Claude Code."""
+
+import json
+import re
+from typing import Optional
+
+import requests
+
+
+def fetch_pr_diff(owner: str, repo: str, pr_number: int, github_token: str) -> str:
+    """Fetch the raw diff of a GitHub PR."""
+    url = f"https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}"
+    headers = {
+        "Authorization": f"token {github_token}",
+        "Accept": "application/vnd.github.v3.diff",
+    }
+    response = requests.get(url, headers=headers)
+    response.raise_for_status()
+    return response.text
+
+
+def fetch_pr_info(owner: str, repo: str, pr_number: int, github_token: str) -> dict:
+    """Fetch PR metadata from GitHub API."""
+    url = f"https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}"
+    headers = {
+        "Authorization": f"token {github_token}",
+        "Accept": "application/vnd.github.v3+json",
+    }
+    response = requests.get(url, headers=headers)
+    response.raise_for_status()
+    return response.json()
+
+
+def post_pr_comment(
+    owner: str, repo