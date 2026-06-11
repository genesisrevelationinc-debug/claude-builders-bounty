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
+  claude-review:
+    runs-on: ubuntu-latest
+    permissions:
+      pull-requests: write
+      contents: read
+
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
+          pip install claude-review
+
+      - name: Get PR diff
+        id: get-diff
+        run: |
+          curl -s -H "Authorization: token ${{ secrets.GITHUB_TOKEN }}" \
+            "${{ github.event.pull_request.diff_url }}" > pr.diff
+
+      - name: Run Claude Review
+        env:
+          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
+          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
+        run: |
+          claude-review --pr "${{ github.event.pull_request.html_url }}" \
+            --diff-file pr.diff \
+            --post-comment
+
--- /dev/null
+++ b/claude_review/__init__.py
@@ -0,0 +1,5 @@
+"""Claude Code PR Review Agent."""
+
+__version__ = "0.1.0"
+
+from .reviewer import ClaudeReviewer
--- /dev/null
+++ b/claude_review/__main__.py
@@ -0,0 +1,6 @@
+"""Entry point for running claude-review as a module."""
+
+from .cli import main
+
+if __name__ == "__main__":
+    main()
--- /dev/null
+++ b/claude_review/cli.py
@@ -0,0 +1,88 @@
+"""Command-line interface for the Claude PR Review agent."""
+
+import argparse
+import os
+import sys
+
+from .reviewer import ClaudeReviewer
+
+
+def create_parser() -> argparse.ArgumentParser:
+    """Create the argument parser for the CLI."""
+    parser = argparse.ArgumentParser(
+        prog="claude-review",
+        description="Claude Code PR Review Agent - Analyze PRs and generate structured review comments.",
+    )
+    parser.add_argument(
+        "--pr",
+        required=True,
+        help="URL of the GitHub PR to review (e.g., https://github.com/owner/repo/pull/123)",
+    )
+    parser.add_argument(
+        "--diff-file",
+        default=None,
+        help="Path to a local diff file (optional; if omitted, fetches via GitHub API)",
+    )
+    parser.add_argument(
+        "--output",
+        "-o",
+        default=None,
+        help="Output file for the review (default: stdout)",
+    )
+    parser.add_argument(
+        "--post-comment",
+        action="store_true",
+        help="Post the review as a comment on the PR (requires GITHUB_TOKEN env var)",
+    )
+    parser.add_argument(
+        "--model",
+        default="claude-sonnet-4-20250514",
+        help="Claude model to use (default: claude-sonnet-4-20250514)",
+    )
+    return parser
+
+
+def main() -> int:
+    """Main entry point for the CLI."""
+    parser = create_parser()
+    args = parser.parse_args()
+
+    api_key = os.environ.get("ANTHROPIC_API_KEY")
+    if not api_key:
+        print("Error: ANTHROPIC_API_KEY environment variable is required.", file=sys.stderr)
+        return 1
+
+    github_token = os.environ.get("GITHUB_TOKEN")
+
+    # Load diff content
+    if args.diff_file:
+        with open(args.diff_file, "r", encoding="utf-8") as f:
+            diff_content = f.read()
+    else:
+        diff_content = None
+
+    reviewer = ClaudeReviewer(api_key=api_key, model=args.model, github_token=github_token)
+
+    try:
+        review = reviewer.review_pr(args.pr, diff_content=diff_content)
+    except Exception as e:
+        print(f"Error generating review: {e}", file=sys.stderr)
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
+        if not github_token:
+            print("Error: GITHUB_TOKEN environment variable is required to post comments.", file=sys.stderr)
+            return 1
+        reviewer.post_pr_comment(args.pr, review)
+
+    return 0
--- /dev/null
+++ b/claude_review/reviewer.py
@@ -0,0 +1,246 @@
+"""Core review logic for the Claude PR Review agent."""
+
+import json
+import os
+import re
+import urllib.request
+from typing import Optional
+
+
+class ClaudeReviewer:
+    """Agent that reviews PR diffs using Claude and produces structured Markdown output."""
+
+    SYSTEM_PROMPT = """You are an expert code reviewer. Analyze the provided PR diff and produce a structured Markdown review with the following sections:
+
+## Summary
+
+A brief 2-3 sentence summary of what the PR does and its intent.
+
+## Risks
+
+A bullet list of potential risks, bugs, or issues introduced by this PR. Be specific and reference line numbers or files where possible. If no risks are found, state that explicitly.
+
+## Improvement Suggestions
+
+A bullet list of concrete suggestions to improve the code quality, performance, maintainability, or security. If the PR is already excellent, acknowledge that.
+
+## Confidence Score
+
+One of: **Low**, **Medium**, or **High** — indicating your overall confidence in the correctness and quality of this PR.
+
+Rules:
+- Be concise but thorough.
+- Do not make assumptions about code you cannot see.
+- Focus on the diff, not the entire codebase.
+- Use Markdown formatting.
+"""
+
+    def __init__(self, api_key: str, model: str = "claude-sonnet-4-20250514", github_token: Optional[str] = None):
+        self.api_key = api_key
+        self.model = model
+        self.github_token = github_token
+        self.api_base = "https://api.anthropic.com/v1