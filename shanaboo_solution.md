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
+      contents: read
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
+        id: get-diff
+        run: |
+          curl -s -H "Authorization: token ${{ secrets.GITHUB_TOKEN }}" \
+            "${{ github.event.pull_request.diff_url }}" > pr.diff
+          echo "diff_file=pr.diff" >> $GITHUB_OUTPUT
+
+      - name: Run Claude Review
+        env:
+          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
+          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
+        run: |
+          claude-review --diff pr.diff \
+            --pr-url "${{ github.event.pull_request.html_url }}" \
+            --post-comment \
+            --github-token "$GITHUB_TOKEN"
+--- /dev/null
+++ b/claude_review/__init__.py
@@ -0,0 +1,5 @@
+"""Claude Code PR Review Agent."""
+
+from .reviewer import ClaudeReviewer
+
+__all__ = ["ClaudeReviewer"]
+--- /dev/null
+++ b/claude_review/__main__.py
@@ -0,0 +1,6 @@
+"""Entry point for python -m claude_review."""
+
+from .cli import main
+
+if __name__ == "__main__":
+    main()
+--- /dev/null
+++ b/claude_review/cli.py
@@ -0,0 +1,93 @@
+"""CLI for the Claude PR Review agent."""
+
+import argparse
+import os
+import sys
+
+from .reviewer import ClaudeReviewer
+
+
+def create_parser() -> argparse.ArgumentParser:
+    parser = argparse.ArgumentParser(
+        prog="claude-review",
+        description="Claude Code PR Review Agent — analyze a PR diff and produce structured Markdown output.",
+    )
+    parser.add_argument(
+        "--pr",
+        dest="pr_url",
+        help="GitHub PR URL (e.g. https://github.com/owner/repo/pull/123)",
+    )
+    parser.add_argument(
+        "--diff",
+        dest="diff_file",
+        help="Path to a .diff / .patch file to review",
+    )
+    parser.add_argument(
+        "--output",
+        "-o",
+        dest="output_file",
+        help="Write review to this file instead of stdout",
+    )
+    parser.add_argument(
+        "--post-comment",
+        action="store_true",
+        help="Post the review as a comment on the PR (requires --pr and GITHUB_TOKEN)",
+    )
+    parser.add_argument(
+        "--github-token",
+        dest="github_token",
+        default=os.environ.get("GITHUB_TOKEN"),
+        help="GitHub personal access token (or set GITHUB_TOKEN env var)",
+    )
+    parser.add_argument(
+        "--model",
+        default=os.environ.get("CLAUDE_MODEL", "claude-sonnet-4-20250514"),
+        help="Claude model identifier (default: claude-sonnet-4-20250514)",
+    )
+    return parser
+
+
+def main() -> None:
+    parser = create_parser()
+    args = parser.parse_args()
+
+    if not args.pr_url and not args.diff_file:
+        print("Error: Must provide either --pr or --diff", file=sys.stderr)
+        sys.exit(1)
+
+    api_key = os.environ.get("ANTHROPIC_API_KEY")
+    if not api_key:
+        print("Error: ANTHROPIC_API_KEY environment variable required", file=sys.stderr)
+        sys.exit(1)
+
+    reviewer = ClaudeReviewer(api_key=api_key, model=args.model)
+
+    if args.pr_url:
+        print(f"Fetching diff from {args.pr_url} ...")
+        diff_text = reviewer.fetch_pr_diff(args.pr_url, token=args.github_token)
+    else:
+        with open(args.diff_file, "r", encoding="utf-8") as f:
+            diff_text = f.read()
+
+    if not diff_text or not diff_text.strip():
+        print("Error: Empty diff", file=sys.stderr)
+        sys.exit(1)
+
+    print("Analyzing with Claude ...")
+    review = reviewer.review(diff_text, pr_url=args.pr_url)
+
+    if args.output_file:
+        with open(args.output_file, "w", encoding="utf-8") as f:
+            f.write(review)
+        print(f"Review written to {args.output_file}")
+    else:
+        print("\n" + "=" * 60)
+        print(review)
+        print("=" * 60)
+
+    if args.post_comment and args.pr_url:
+        reviewer.post_comment(args.pr_url, review, token=args.github_token)
+        print("Comment posted to PR.")
+--- /dev/null
+++ b/claude_review/reviewer.py
@@ -0,0 +1,186 @@
+"""Core review logic for the Claude PR Review agent."""
+
+import json
+import os
+import re
+import textwrap
+from typing import Optional
+
+import requests
+
+
+SYSTEM_PROMPT = """\
+You are an expert software engineer and code reviewer. Analyze the provided PR diff and produce a structured review in Markdown.
+
+Your response must follow this exact format:
+
+## Summary
+
+2–3 sentences summarizing the changes.
+
+## Risks
+
+- Risk 1
+- Risk 2
+- Risk 3
+
+## Suggestions
+
+- Suggestion 1
+- Suggestion 2
+
+## Confidence
+
+Low / Medium / High
+
+Rules:
+- Be concise but thorough.
+- Flag security issues, logic errors, missing tests, and breaking changes.
+- Suggest concrete improvements, not vague advice.
+- Confidence reflects how certain you are about the risks identified.
+"""
+
+
+class ClaudeReviewer:
+    def __init__(self, api_key: str, model: str = "claude-sonnet-4-20250514"):
+        self.api_key = api_key
+       