 ```diff
--- /dev/null
+++ b/claude-review
@@ -0,0 +1,3 @@
+#!/usr/bin/env bash
+SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
+exec python3 "$SCRIPT_DIR/claude_review/cli.py" "$@"
--- /dev/null
+++ 	claude_review/__init__.py
@@ -0,0 +1,3 @@
+"""Claude Code PR Review Agent."""
+
+__version__ = "0.1.0"
--- /dev/null
+++ 	claude_review/cli.py
@@ -0,0 +1,95 @@
+#!/usr/bin/env python3
+"""CLI entry point for the Claude Code PR reviewer."""
+
+import argparse
+import os
+import sys
+
+from .reviewer import PRReviewer
+
+
+def main():
+    parser = argparse.ArgumentParser(
+        description="Claude Code PR Review Agent - Analyze PRs and generate structured review comments."
+    )
+    parser.add_argument(
+        "--pr",
+        required=True,
+        help="GitHub PR URL (e.g., https://github.com/owner/repo/pull/123)",
+    )
+    parser.add_argument(
+        "--api-key",
+        default=os.environ.get("ANTHROPIC_API_KEY"),
+        help="Anthropic API key (or set ANTHROPIC_API_KEY env var)",
+    )
+    parser.add_argument(
+        "--github-token",
+        default=os.environ.get("GITHUB_TOKEN"),
+        help="GitHub personal access token (or set GITHUB_TOKEN env var)",
+    )
+    parser.add_argument(
+        "--post-comment",
+        action="store_true",
+        help="Post the review as a comment on the PR",
+    )
+    parser.add_argument(
+        "--model",
+        default="claude-sonnet-4-20250514",
+        help="Claude model to use (default: claude-sonnet-4-20250514)",
+    )
+    parser.add_argument(
+        "--output",
+        "-o",
+        help="Write review to file instead of stdout",
+    )
+
+    args = parser.parse_args()
+
+    if not args.api_key:
+        print(
+            "Error: Anthropic API key required. Set ANTHROPIC_API_KEY or use --api-key.",
+            file=sys.stderr,
+        )
+        sys.exit(1)
+
+    reviewer = PRReviewer(
+        api_key=args.api_key,
+        github_token=args.github_token,
+        model=args.model,
+    )
+
+    try:
+        # Fetch PR diff
+        print(f"Fetching PR diff from {args.pr}...", file=sys.stderr)
+        diff_content = reviewer.fetch_pr_diff(args.pr)
+
+        # Generate review
+        print("Analyzing with Claude...", file=sys.stderr)
+        review = reviewer.generate_review(args.pr, diff_content)
+
+        # Output review
+        if args.output:
+            with open(args.output, "w") as f:
+                f.write(review)
+            print(f"Review written to {args.output}", file=sys.stderr)
+        else:
+            print(review)
+
+        # Post comment if requested
+        if args.post_comment:
+            if not args.github_token:
+                print("Error: GITHUB_TOKEN required to post comments.", file=sys.stderr)
+                sys.exit(1)
+            reviewer.post_review_comment(args.pr, review)
+            print("Review posted as PR comment.", file=sys.stderr)
+
+    except Exception as e:
+        print(f"Error: {e}", file=sys.stderr)
+        sys.exit(1)
+
+
+if __name__ == "__main__":
+    main()
--- /dev/null
+++ 	claude_review/reviewer.py
@@ -0,0 +1,198 @@
+"""Core PR review logic using Claude Code."""
+
+import json
+import re
+import urllib.request
+from typing import Optional
+
+
+class PRReviewer:
+    def __init__(self, api_key: str, github_token: Optional[str] = None, model: str = "claude-sonnet-4-20250514"):
+        self.api_key = api_key
+        self.github_token = github_token
+        self.model = model
+        self.anthropic_api_url = "https://api.anthropic.com/v1/messages"
+
+    def _parse_pr_url(self, pr_url: str) -> tuple:
+        """Parse GitHub PR URL into (owner, repo, pr_number)."""
+        match = re.match(r"https?://github\.com/([^/]+)/([^/]+)/pull/(\d+)", pr_url)
+        if not match:
+            raise ValueError(f"Invalid GitHub PR URL: {pr_url}")
+        return match.group(1), match.group(2), match.group(3)
+
+    def fetch_pr_diff(self, pr_url: str) -> str:
+        """Fetch the raw diff of a GitHub PR."""
+        owner, repo, pr_number = self._parse_pr_url(pr_url)
+        diff_url = f"https://github.com/{owner}/{repo}/pull/{pr_number}.diff"
+
+        req = urllib.request.Request(diff_url)
+        req.add_header("Accept", "application/vnd.github.v3.diff")
+        if self.github_token:
+            req.add_header("Authorization", f"token {self.github_token}")
+
+        with urllib.request.urlopen(req, timeout=30) as response:
+            return response.read().decode("utf-8")
+
+    def _call_claude_api(self, messages: list, max_tokens: int = 4096) -> str:
+        """Call the Anthropic Claude API."""
+        headers = {
+            "Content-Type": "application/json",
+            "X-API-Key": self.api_key,
+            "anthropic-version": "2023-06-01",
+        }
+
+        payload = {
+            "model": self.model,
+            "max_tokens": max_tokens,
+            "messages": messages,
+        }
+
+        req = urllib.request.Request(
+            self.anthropic_api_url,
+            data=json.dumps(payload).encode("utf-8"),
+            headers=headers,
+            method="POST",
+        )
+
+        with urllib.request.urlopen(req, timeout=120) as response:
+            result = json.loads(response.read().decode("utf-8"))
+            return result["content"][0]["text"]
+
+    def generate_review(self, pr_url: str, diff_content: str) -> str:
+        """Generate a structured Markdown review using Claude."""
+        system_prompt = """You are an expert code reviewer. Analyze the provided PR diff and generate a structured Markdown review comment.
+
+Your review must follow this exact format:
+
