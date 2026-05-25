```diff
--- /dev/null
+++ b/claude-review
@@ -0,0 +1,2 @@
+#!/usr/bin/env bash
+exec python3 -m claude_review.cli "$@"
--- /dev/null
+++ b/claude_review/__init__.py
@@ -0,0 +1,3 @@
+"""Claude Code PR Review Agent."""
+
+__version__ = "0.1.0"
--- /dev/null
+++ b/claude_review/cli.py
@@ -0,0 +1,95 @@
+#!/usr/bin/env python3
+"""CLI entry-point for the Claude Code PR review agent."""
+
+import argparse
+import os
+import re
+import subprocess
+import sys
+from urllib.parse import urlparse
+
+from .reviewer import review_pr
+
+
+def extract_pr_info(pr_url: str) -> tuple[str, str, int]:
+    """Extract owner, repo, and PR number from a GitHub PR URL."""
+    parsed = urlparse(pr_url)
+    # Path looks like /owner/repo/pull/123
+    match = re.match(r"^/([^/]+)/([^/]+)/pull/(\d+)", parsed.path)
+    if not match:
+        raise ValueError(f"Invalid PR URL: {pr_url}")
+    return match.group(1), match.group(2), int(match.group(3))
+
+
+def fetch_pr_diff(owner: str, repo: str, pr_number: int, token: str | None = None) -> str:
+    """Fetch the PR diff from GitHub API."""
+    import urllib.request
+
+    url = f"https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}"
+    headers = {
+        "Accept": "application/vnd.github.v3.diff",
+        "User-Agent": "claude-review/0.1.0",
+    }
+    if token:
+        headers["Authorization"] = f"Bearer {token}"
+
+    req = urllib.request.Request(url, headers=headers)
+    with urllib.request.urlopen(req, timeout=30) as response:
+        return response.read().decode("utf-8")
+
+
+def post_comment(owner: str, repo: str, pr_number: int, body: str, token: str) -> dict:
+    """Post a review comment to the PR."""
+    import json
+    import urllib.request
+
+    url = f"https://api.github.com/repos/{owner}/{repo}/issues/{pr_number}/comments"
+    data = json.dumps({"body": body}).encode("utf-8")
+    headers = {
+        "Authorization": f"Bearer {token}",
+        "Content-Type": "application/json",
+        "User-Agent": "claude-review/0.1.0",
+    }
+
+    req = urllib.request.Request(url, data=data, headers=headers, method="POST")
+    with urllib.request.urlopen(req, timeout=30) as response:
+        return json.loads(response.read().decode("utf-8"))
+
+
+def main() -> int:
+    parser = argparse.ArgumentParser(description="Claude Code PR Review Agent")
+    parser.add_argument("--pr", required=True, help="GitHub PR URL to review")
+    parser.add_argument("--post", action="store_true", help="Post review as a comment to the PR")
+    args = parser.parse_args()
+
+    token = os.environ.get("GITHUB_TOKEN")
+    if args.post and not token:
+        print("Error: GITHUB_TOKEN required when using --post", file=sys.stderr)
+        return 1
+
+    try:
+        owner, repo, pr_number = extract_pr_info(args.pr)
+    except ValueError as e:
+        print(f"Error: {e}", file=sys.stderr)
+        return 1
+
+    print(f"Fetching diff for {owner}/{repo}#{pr_number} ...")
+    diff = fetch_pr_diff(owner, repo, pr_number, token)
+
+    print("Reviewing with Claude ...")
+    review = review_pr(diff, pr_url=args.pr)
+
+    if args.post and token:
+        print("Posting comment ...")
+        post_comment(owner, repo, pr_number, review, token)
+
+    print(review)
+    return 0
+
+
+if __name__ == "__main__":
+    sys.exit(main())
--- /dev/null
+++ b/claude_review/reviewer.py
@@ -0,0 +1,143 @@
+"""Core review logic using Claude Code / Anthropic API."""
+
+import json
+import os
+import re
+import subprocess
+import sys
+from dataclasses import dataclass
+from typing import Literal
+
+
+Confidence = Literal["Low", "Medium", "High"]
+
+
+@dataclass
+class ReviewResult:
+    summary: str
+    risks: list[str]
+    suggestions: list[str]
+    confidence: Confidence
+
+
+def _call_claude_code(prompt: str) -> str:
+    """Call Claude Code via subprocess and return its response."""
+    # Prefer `claude` CLI if available (Claude Code desktop)
+    claude_path = os.environ.get("CLAUDE_CODE_PATH", "claude")
+
+    # Try Claude Code CLI first
+    try:
+        result = subprocess.run(
+            [claude_path, "ask", "--print", prompt],
+            capture_output=True,
+            text=True,
+            timeout=300,
+            check=False,
+        )
+        if result.returncode == 0 and result.stdout.strip():
+            return result.stdout.strip()
+    except (FileNotFoundError, subprocess.TimeoutExpired):
+        pass
+
+    # Fallback to Anthropic API directly
+    return _call_anthropic_api(prompt)
+
+
+def _call_anthropic_api(prompt: str) -> str:
+    """Fallback to Anthropic API if Claude Code CLI is not available."""
+    import urllib.request
+
+    api_key = os.environ.get("ANTHROPIC_API_KEY")
+    if not api_key:
+        raise RuntimeError(
+            "Claude Code CLI not found and ANTHROPIC_API_KEY not set. "
+            "Please install Claude Code or set ANTHROPIC_API_KEY."
+        )
+
+    url = "https://api.anthropic.com/v1/messages"
+    data = json.dumps({
+        "model": "claude-sonnet-4-20250514",
+        "max_tokens": 4096,
+        "messages": [{"role": "user", "content": prompt}],
+    }).encode("utf-8")
+
+    headers = {
+        "Content-Type": "application/json",
+        "x-api-key": api_key,
+        "anthropic-version": "2023-06-01",
+   