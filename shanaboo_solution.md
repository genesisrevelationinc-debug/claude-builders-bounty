 ```diff
--- /dev/null
+++ b/.github/workflows/claude-review.yml
@@ -0,0 +1,39 @@
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
+      - name: Run Claude PR Review
+        env:
+          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
+          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
+          PR_URL: ${{ github.event.pull_request.html_url }}
+        run: |
+          claude-review --pr "$PR_URL" --output review.md
+
+      - name: Post review comment
+        uses: marocchino/sticky-pull-request-comment@v2
+        with:
+          path: review.md
+          header: claude-review
+--- /dev/null
+++ b/claude_review/__init__.py
@@ -0,0 +1,5 @@
+"""Claude Code PR Review Agent."""
+
+__version__ = "0.1.0"
+
+from .reviewer import review_pr, main
--- /dev/null
+++ b/claude_review/reviewer.py
@@ -0,0 +1,268 @@
+#!/usr/bin/env python3
+"""Claude Code PR Review Agent.
+
+Takes a PR diff as input, analyzes it with Claude, and returns a structured
+Markdown review comment.
+"""
+
+from __future__ import annotations
+
+import argparse
+import json
+import os
+import re
+import subprocess
+import sys
+from dataclasses import dataclass
+from pathlib import Path
+from typing import Any
+
+try:
+    import requests
+except ImportError:  # pragma: no cover
+    requests = None  # type: ignore[assignment]
+
+
+ANTHROPIC_API_URL = "https://api.anthropic.com/v1/messages"
+DEFAULT_MODEL = "claude-sonnet-4-20250514"
+
+
+@dataclass
+class ReviewResult:
+    """Structured PR review result."""
+
+    summary: str
+    risks: list[str]
+    suggestions: list[str]
+    confidence: str
+
+    def to_markdown(self) -> str:
+        """Convert review to structured Markdown."""
+        risks_md = "\n".join(f"- {r}" for r in self.risks) or "- None identified"
+        suggestions_md = "\n".join(f"- {s}" for s in self.suggestions) or "- None"
+
+        return f"""## 🤖 Claude PR Review
+
+### Summary
+{self.summary}
+
+### Identified Risks
+{risks_md}
+
+### Improvement Suggestions
+{suggestions_md}
+
+### Confidence Score
+**{self.confidence}**
+
+---
+*Reviewed by Claude Code · {DEFAULT_MODEL}*
+"""
+
+
+def get_pr_diff_from_url(pr_url: str) -> str:
+    """Fetch PR diff from GitHub API or git CLI."""
+    # Try to extract owner/repo/number from URL
+    match = re.match(r"https://github\.com/([^/]+)/([^/]+)/pull/(\d+)", pr_url)
+    if not match:
+        raise ValueError(f"Invalid GitHub PR URL: {pr_url}")
+
+    owner, repo, pr_number = match.groups()
+
+    # Try GitHub API first
+    token = os.environ.get("GITHUB_TOKEN")
+    if token and requests:
+        api_url = f"https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}"
+        headers = {
+            "Authorization": f"token {token}",
+            "Accept": "application/vnd.github.v3.diff",
+        }
+        resp = requests.get(api_url, headers=headers, timeout=30)
+        if resp.status_code == 200:
+            return resp.text
+
+    # Fallback: try gh CLI
+    try:
+        result = subprocess.run(
+            ["gh", "pr", "view", pr_number, "--repo", f"{owner}/{repo}", "--json", "diff"],
+            capture_output=True,
+            text=True,
+            check=True,
+            timeout=30,
+        )
+        data = json.loads(result.stdout)
+        diff = data.get("diff", "")
+        if diff:
+            return diff
+    except (subprocess.CalledProcessError, FileNotFoundError, json.JSONDecodeError):
+        pass
+
+    # Fallback: try git fetch and diff
+    try:
+        result = subprocess.run(
+            [
+                "git",
+                "fetch",
+                "origin",
+                f"pull/{pr_number}/head:pr-{pr_number}",
+            ],
+            capture_output=True,
+            text=True,
+            check=False,
+            timeout=30,
+        )
+        # Get diff against base
+        result = subprocess.run(
+            ["git", "diff", "origin/main...", f"pr-{pr_number}"],
+            capture_output=True,
+            text=True,
+            check=False,
+            timeout=30,
+        )
+        if result.returncode == 0 and result.stdout:
+            return result.stdout
+    except (subprocess.CalledProcessError, FileNotFoundError):
+        pass
+
+    raise RuntimeError(f"Could not fetch diff for PR: {pr_url}")
+
+
+def call_claude(diff_text: str, model: str | None = None) -> ReviewResult:
+    """Send diff to Claude API and parse structured review."""
+    api_key = os.environ.get("ANTHROPIC_API_KEY")
+    if not api_key:
+        raise RuntimeError("ANTHROPIC_API_KEY environment variable not set")
+
+    if requests is None:
+        raise RuntimeError("requests library not installed")
+
+    # Truncate diff if too large
+    max_diff_chars = 100000
+    if len(diff_text) > max_diff_chars:
+        diff_text = diff_text[:max_diff_chars] + "\n\n[... diff truncated ...]"
+
+    prompt = f"""You are a senior software engineer performing a code review.
+Analyze the following PR diff and provide a