 ```diff
--- /dev/null
+++ b/claude-review
@@ -0,0 +1,3 @@
+#!/usr/bin/env bash
+set -euo pipefail
+exec python3 -m claude_review "$@"
--- /dev/null
+++ claude_review/__init__.py
@@ -0,0 +1,3 @@
+"""Claude Code PR Review Agent."""
+
+__version__ = "0.1.0"
--- /dev/null
+++ claude_review/__main__.py
@@ -0,0 +1,6 @@
+"""Entry point for python -m claude_review."""
+
+from claude_review.cli import main
+
+if __name__ == "__main__":
+    main()
--- /dev/null
+++ claude_review/cli.py
@@ -0,0 +1,96 @@
+"""CLI for the Claude Code PR Review Agent."""
+
+from __future__ import annotations
+
+import argparse
+import os
+import sys
+
+from claude_review.review import review_pull_request
+
+
+def _validate_pr_url(url: str) -> str:
+    """Validate that the URL looks like a GitHub PR URL."""
+    if not url.startswith("https://github.com/"):
+        raise argparse.ArgumentTypeError(
+            f"PR URL must start with https://github.com/: {url}"
+        )
+    parts = url.rstrip("/").split("/")
+    if len(parts) < 7 or parts[-2] != "pull":
+        raise argparse.ArgumentTypeError(
+            f"URL must be a GitHub pull request URL: {url}"
+        )
+    return url
+
+
+def _build_parser() -> argparse.ArgumentParser:
+    parser = argparse.ArgumentParser(
+        prog="claude-review",
+        description="Claude Code PR Review Agent — structured Markdown review comments.",
+    )
+    parser.add_argument(
+        "--pr",
+        dest="pr_url",
+        required=True,
+        type=_validate_pr_url,
+        help="GitHub pull request URL to review (e.g. https://github.com/owner/repo/pull/123)",
+    )
+    parser.add_argument(
+        "--api-key",
+        dest="api_key",
+        default=os.environ.get("ANTHROPIC_API_KEY"),
+        help="Anthropic API key (defaults to ANTHROPIC_API_KEY env var)",
+    )
+    parser.add_argument(
+        "--github-token",
+        dest="github_token",
+        default=os.environ.get("GITHUB_TOKEN"),
+        help="GitHub token for posting comments (defaults to GITHUB_TOKEN env var)",
+    )
+    parser.add_argument(
+        "--output",
+        dest="output",
+        choices=["stdout", "github"],
+        default="stdout",
+        help="Where to output the review (default: stdout)",
+    )
+    parser.add_argument(
+        "--model",
+        dest="model",
+        default="claude-sonnet-4-20250514",
+        help="Claude model to use (default: claude-sonnet-4-20250514)",
+    )
+    return parser
+
+
+def main(argv: list[str] | None = None) -> int:
+    parser = _build_parser()
+    args = parser.parse_args(argv)
+
+    if not args.api_key:
+        print(
+            "Error: Anthropic API key required. Set ANTHROPIC_API_KEY or pass --api-key.",
+            file=sys.stderr,
+        )
+        return 1
+
+    try:
+        review_pull_request(
+            pr_url=args.pr_url,
+            api_key=args.api_key,
+            github_token=args.github_token,
+            output=args.output,
+            model=args.model,
+        )
+    except Exception as exc:  # noqa: BLE001
+        print(f"Error: {exc}", file=sys.stderr)
+        return 1
+    return 0
+
+
+if __name__ == "__main__":
+    raise SystemExit(main())
--- /dev/null
+++ claude_review/github_client.py
@@ -0,0 +1,80 @@
+"""GitHub API client for fetching PR diffs and posting comments."""
+
+from __future__ import annotations
+
+import json
+import re
+import urllib.request
+from typing import Any
+
+
+class GitHubClient:
+    """Minimal GitHub API client."""
+
+    def __init__(self, token: str | None = None) -> None:
+        self.token = token
+
+    def _headers(self) -> dict[str, str]:
+        headers = {
+            "Accept": "application/vnd.github.v3+json",
+            "User-Agent": "claude-review/0.1.0",
+        }
+        if self.token:
+            headers["Authorization"] = f"token {self.token}"
+        return headers
+
+    def _request(
+        self, url: str, method: str = "GET", data: dict[str, Any] | None = None
+    ) -> Any:
+        req = urllib.request.Request(
+            url,
+            method=method,
+            headers=self._headers(),
+        )
+        if data is not None:
+            body = json.dumps(data).encode("utf-8")
+            req.add_header("Content-Type", "application/json")
+            req.data = body  # type: ignore[attr-defined]
+
+        with urllib.request.urlopen(req) as response:
+            return json.loads(response.read().decode("utf-8"))
+
+    def get_pr_diff(self, pr_url: str) -> str:
+        """Fetch the raw diff for a pull request."""
+        # Convert PR URL to diff URL
+        diff_url = pr_url.rstrip("/") + ".diff"
+        req = urllib.request.Request(
+            diff_url,
+            headers={
+                "Accept": "application/vnd.github.v3.diff",
+                "User-Agent": "claude-review/0.1.0",
+            },
+        )
+        with urllib.request.urlopen(req) as response:
+            return response.read().decode("utf-8")
+
+    def post_pr_comment(self, pr_url: str, body: str) -> None:
+        """Post a comment on a pull request."""
+        if not self.token:
+            raise RuntimeError("GitHub token required to post comments")
+
+        # Extract owner, repo, and PR number from URL
+        match = re.match(
+            r"https://github\.com/([^/]+)/([^/]+)/pull/(\d+)", pr_url
+        )
+        if not match:
+            raise ValueError(f"Invalid PR URL: {pr_url}")
+
+        owner, repo, pr_number = match.groups()
+        api_url = (
+            f"https