 ```diff
--- /dev/null
+++ b/claude-review
@@ -0,0 +1,3 @@
+#!/usr/bin/env bash
+set -euo pipefail
+exec python3 "$(dirname "$0")/claude_review/cli.py" "$@"
--- /dev/null
+++ b/claude_review/__init__.py
@@ -0,0 +1,5 @@
+"""Claude Code PR Review Agent."""
+
+__version__ = "0.1.0"
+__all__ = ["review_pr", "format_review"]
+
--- /dev/null
+++ b/claude_review/cli.py
@@ -0,0 +1,120 @@
+#!/usr/bin/env python3
+"""CLI entry point for the Claude Code PR reviewer agent."""
+
+from __future__ import annotations
+
+import argparse
+import os
+import re
+import subprocess
+import sys
+import urllib.request
+from pathlib import Path
+
+from .reviewer import review_pr
+
+
+def _fetch_diff(pr_url: str) -> str:
+    """Fetch raw diff from a GitHub PR URL."""
+    # Normalize PR URL to raw diff URL
+    # Supported formats:
+    #   https://github.com/owner/repo/pull/123
+    #   https://github.com/owner/repo/pull/123/files
+    match = re.match(r"https?://github\.com/([^/]+)/([^/]+)/pull/(\d+)", pr_url)
+    if not match:
+        raise ValueError(f"Invalid GitHub PR URL: {pr_url}")
+
+    owner, repo, pr_number = match.groups()
+    diff_url = f"https://github.com/{owner}/{repo}/pull/{pr_number}.diff"
+
+    req = urllib.request.Request(
+        diff_url,
+        headers={
+            "User-Agent": "claude-review/0.1.0",
+            "Accept": "application/vnd.github.v3.diff",
+        },
+    )
+
+    token = os.environ.get("GITHUB_TOKEN")
+    if token:
+        req.add_header("Authorization", f"token {token}")
+
+    with urllib.request.urlopen(req, timeout=30) as response:
+        return response.read().decode("utf-8")
+
+
+def _read_diff_from_file(path: str) -> str:
+    """Read diff from a local file."""
+    return Path(path).read_text(encoding="utf-8")
+
+
+def _read_diff_from_stdin() -> str:
+    """Read diff from stdin."""
+    return sys.stdin.read()
+
+
+def _get_git_diff() -> str:
+    """Get diff from git if in a repo."""
+    result = subprocess.run(
+        ["git", "diff", "HEAD~1", "HEAD"],
+        capture_output=True,
+        text=True,
+        check=False,
+    )
+    if result.returncode != 0:
+        raise RuntimeError("Failed to get git diff. Are you in a git repository?")
+    return result.stdout
+
+
+def main() -> None:
+    parser = argparse.ArgumentParser(
+        description="Claude Code PR Review Agent",
+        formatter_class=argparse.RawDescriptionHelpFormatter,
+        epilog="""
+Examples:
+  claude-review --pr https://github.com/owner/repo/pull/123
+  claude-review --file changes.diff
+  git diff | claude-review --stdin
+  claude-review --git
+        """,
+    )
+    group = parser.add_mutually_exclusive_group(required=True)
+    group.add_argument("--pr", help="GitHub PR URL to review")
+    group.add_argument("--file", help="Path to a local diff file")
+    group.add_argument("--stdin", action="store_true", help="Read diff from stdin")
+    group.add_argument("--git", action="store_true", help="Review last git commit")
+
+    parser.add_argument("--api-key", help="Anthropic API key (or set ANTHROPIC_API_KEY)")
+    parser.add_argument("--model", default="claude-sonnet-4-20250514", help="Claude model to use")
+    parser.add_argument("--output", "-o", help="Write review to file instead of stdout")
+
+    args = parser.parse_args()
+
+    if args.pr:
+        diff_text = _fetch_diff(args.pr)
+    elif args.file:
+        diff_text = _read_diff_from_file(args.file)
+    elif args.stdin:
+        diff_text = _read_diff_from_stdin()
+    else:
+        diff_text = _get_git_diff()
+
+    review = review_pr(diff_text, api_key=args.api_key, model=args.model, pr_url=args.pr)
+
+    if args.output:
+        Path(args.output).write_text(review, encoding="utf-8")
+    else:
+        print(review)
+
+
+if __name__ == "__main__":
+    main()
--- /dev/null
+++ b/claude_review/reviewer.py
@@ -0,0 +1,189 @@
+"""Core PR review logic using Claude API."""
+
+from __future__ import annotations
+
+import json
+import os
+import re
+from dataclasses import dataclass
+from typing import Any
+
+
+@dataclass
+class ReviewResult:
+    summary: str
+    risks: list[str]
+    suggestions: list[str]
+    confidence: str
+
+
+def _call_claude_api(diff_text: str, api_key: str | None, model: str, pr_url: str | None = None) -> str:
+    """Call the Claude API to analyze a PR diff."""
+    import urllib.request
+
+    key = api_key or os.environ.get("ANTHROPIC_API_KEY")
+    if not key:
+        raise RuntimeError(
+            "Anthropic API key required. Set ANTHROPIC_API_KEY or pass --api-key."
+        )
+
+    # Truncate very large diffs
+    max_diff_chars = 100_000
+    if len(diff_text) > max_diff_chars:
+        diff_text = diff_text[:max_diff_chars] + "\n\n[... diff truncated ...]"
+
+    pr_context = f"PR: {pr_url}\n" if pr_url else ""
+
+    system_prompt = (
+        "You are an expert code reviewer. Analyze the provided PR diff and produce "
+        "a structured review in JSON format with these fields:\n"
+        "- summary: A concise 2-3 sentence summary of the changes\n"
+        "- risks: A list of identified risks or concerns (can be empty)\n"
+        "- suggestions: A list of improvement suggestions (can be empty)\n"
+        "- confidence: One of 'Low', 'Medium', or 'High' indicating your confidence