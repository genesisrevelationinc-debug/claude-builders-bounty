```diff
--- /dev/null
+++ b/claude-review
@@ -0,0 +1,3 @@
+#!/usr/bin/env bash
+set -euo pipefail
+exec python3 -m claude_review.cli "$@"
--- /dev/null
+++ b/claude_review/__init__.py
@@ -0,0 +1,1 @@
+"""Claude Code PR Review Agent."""
--- /dev/null
+++ b/claude_review/cli.py
@@ -0,0 +1,68 @@
+"""CLI entry-point for the Claude Code PR review agent."""
+
+from __future__ import annotations
+
+import argparse
+import os
+import sys
+
+from .reviewer import review_pr
+
+
+def main(argv: list[str] | None = None) -> int:
+    parser = argparse.ArgumentParser(
+        prog="claude-review",
+        description="Claude Code PR Review Agent — structured Markdown review comments.",
+    )
+    parser.add_argument(
+        "--pr",
+        required=True,
+        help="GitHub PR URL (e.g. https://github.com/owner/repo/pull/123)",
+    )
+    parser.add_argument(
+        "--api-key",
+        default=os.getenv("ANTHROPIC_API_KEY"),
+        help="Anthropic API key (defaults to ANTHROPIC_API_KEY env var)",
+    )
+    parser.add_argument(
+        "--model",
+        default="claude-sonnet-4-20250514",
+        help="Anthropic model to use (default: claude-sonnet-4-20250514)",
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
+
+    args = parser.parse_args(argv)
+
+    if not args.api_key:
+        print(
+            "Error: Anthropic API key required. Set ANTHROPIC_API_KEY or pass --api-key.",
+            file=sys.stderr,
+        )
+        return 1
+
+    review = review_pr(
+        pr_url=args.pr,
+        api_key=args.api_key,
+        model=args.model,
+        post_comment=args.post_comment,
+    )
+
+    if args.output:
+        with open(args.output, "w", encoding="utf-8") as f:
+            f.write(review)
+    else:
+        print(review)
+
+    return 0
+
+
+if __name__ == "__main__":
+    raise SystemExit(main())
--- /dev/null
+++ b/claude_review/reviewer.py
@@ -0,0 +1,213 @@
+"""Core PR review logic using Claude Code / Anthropic API."""
+
+from __future__ import annotations
+
+import json
+import os
+import re
+import subprocess
+import tempfile
+from pathlib import Path
+
+try:
+    import anthropic
+except ImportError:  # pragma: no cover
+    anthropic = None  # type: ignore[assignment]
+
+
+SYSTEM_PROMPT = """\
+You are an elite software engineer performing code review on a GitHub pull request.
+Analyze the diff carefully. Be concise but thorough.
+
+Respond ONLY with a JSON object in this exact shape:
+
+{
+  "summary": "string (2-3 sentences describing what the PR does)",
+  "risks": ["list of specific risks or concerns"],
+  "suggestions": ["list of concrete improvement suggestions"],
+  "confidence": "Low|Medium|High"
+}
+
+Rules:
+- summary: 2-3 sentences, plain English, no jargon.
+- risks: empty list if none; otherwise specific, actionable items.
+- suggestions: empty list if none; otherwise specific and actionable.
+- confidence: Low = major concerns, Medium = minor issues, High = LGTM.
+"""
+
+
+def _run(cmd: list[str], cwd: str | None = None) -> str:
+    result = subprocess.run(
+        cmd,
+        capture_output=True,
+        text=True,
+        cwd=cwd,
+        check=True,
+    )
+    return result.stdout
+
+
+def _parse_pr_url(pr_url: str) -> tuple[str, str, int]:
+    """Extract owner, repo, and PR number from a GitHub PR URL."""
+    patterns = [
+        r"github\.com/(?P<owner>[^/]+)/(?P<repo>[^/]+)/pull/(?P<number>\d+)",
+        r"github\.com/(?P<owner>[^/]+)/(?P<repo>[^/]+)/pulls/(?P<number>\d+)",
+    ]
+    for pattern in patterns:
+        match = re.search(pattern, pr_url)
+        if match:
+            return (
+                match.group("owner"),
+                match.group("repo"),
+                int(match.group("number")),
+            )
+    raise ValueError(f"Could not parse PR URL: {pr_url}")
+
+
+def _fetch_diff(pr_url: str) -> str:
+    """Fetch the diff for a PR using gh CLI or curl."""
+    # Try gh CLI first
+    try:
+        _run(["gh", "--version"])
+    except (subprocess.CalledProcessError, FileNotFoundError):
+        pass
+    else:
+        return _run(["gh", "pr", "view", pr_url, "--json", "diff"])
+
+    # Fallback: use curl with the .diff endpoint
+    match = re.search(r"github\.com/([^/]+)/([^/]+)/pull/(\d+)", pr_url)
+    if match:
+        owner, repo, number = match.groups()
+        diff_url = f"https://github.com/{owner}/{repo}/pull/{number}.diff"
+        return _run(["curl", "-sL", diff_url])
+
+    raise RuntimeError(f"Cannot fetch diff for {pr_url}")
+
+
+def _call_claude(
+    diff: str,
+    api_key: str,
+    model: str,
+) -> dict:
+    """Send the diff to Claude and return structured JSON."""
+    if anthropic is None:
+        raise RuntimeError(
+            "anthropic package not installed. Run: pip install anthropic"
+        )
+
+    client = anthropic.Anthropic(api_key=api_key)
+
+    # Truncate very large diffs
+    max_chars = 100_000
+    if len(diff) > max_chars:
+        diff = diff[:max_chars] + "\n\n[... diff truncated ...]"
+
+    response = client.messages.create(
