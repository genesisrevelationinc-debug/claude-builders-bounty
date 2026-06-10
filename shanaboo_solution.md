 ```diff
--- /dev/null
+++ b/.github/workflows/claude-review.yml
@@ -0,0 +1,40 @@
+name: Claude PR Review
+
+on:
+  pull_request:
+    types: [opened, synchronize, reopened]
+
+permissions:
+  pull-requests: write
+  contents: read
+
+jobs:
+  claude-review:
+    runs-on: ubuntu-latest
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
+          pip install -r claude-review/requirements.txt
+
+      - name: Run Claude PR Review
+        env:
+          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
+          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
+          PR_URL: ${{ github.event.pull_request.html_url }}
+        run: |
+          python -m claude-review.cli --pr "$PR_URL"
+
+      - name: Post review comment
+        uses: actions/github-script@v7
+        with:
+          script: |
+            const fs = require('fs');
+            const review = fs.readFileSync('review_output.md', 'utf8');
+            github.rest.issues.createComment({
+              issue_number: context.issue.number,
+              owner: context.repo.owner,
+              repo: context.repo.repo,
+              body: review
+            });
--- /dev/null
+++ b/claude-review/__init__.py
@@ -0,0 +1,3 @@
+"""Claude Code PR Review Agent."""
+
+__version__ = "0.1.0"
--- /dev/null
+++ b/claude-review/cli.py
@@ -0,0 +1,60 @@
+#!/usr/bin/env python3
+"""CLI entry point for the Claude PR Review agent."""
+
+import argparse
+import os
+import sys
+
+from .reviewer import ClaudePRReviewer
+
+
+def main():
+    parser = argparse.ArgumentParser(
+        description="Claude Code PR Review Agent - Analyze pull requests with AI"
+    )
+    parser.add_argument(
+        "--pr",
+        required=True,
+        help="GitHub PR URL (e.g., https://github.com/owner/repo/pull/123)",
+    )
+    parser.add_argument(
+        "--output",
+        "-o",
+        default="review_output.md",
+        help="Output file for the review (default: review_output.md)",
+    )
+    parser.add_argument(
+        "--api-key",
+        default=os.environ.get("ANTHROPIC_API_KEY"),
+        help="Anthropic API key (or set ANTHROPIC_API_KEY env var)",
+    )
+    parser.add_argument(
+        "--github-token",
+        default=os.environ.get("GITHUB_TOKEN"),
+        help="GitHub token for API access (or set GITHUB_TOKEN env var)",
+    )
+
+    args = parser.parse_args()
+
+    if not args.api_key:
+        print("Error: Anthropic API key required. Set ANTHROPIC_API_KEY or use --api-key", file=sys.stderr)
+        sys.exit(1)
+
+    if not args.github_token:
+        print("Error: GitHub token required. Set GITHUB_TOKEN or use --github-token", file=sys.stderr)
+        sys.exit(1)
+
+    reviewer = ClaudePRReviewer(
+        anthropic_api_key=args.api_key,
+        github_token=args.github_token,
+    )
+
+    review = reviewer.review_pr(args.pr)
+
+    with open(args.output, "w") as f:
+        f.write(review)
+
+    print(f"Review saved to {args.output}")
+    print(review)
+
+
+if __name__ == "__main__":
+    main()
--- /dev/null
+++	@@ -0,0 +1,3 @@
+"""Claude Code PR Review Agent."""
+
+__version__ = "0.1.0"
--- /dev/null
+++	@@ -0,0 +1,60 @@
+#!/usr/bin/env python3
+"""CLI entry point for the Claude PR Review agent."""
+
+import argparse
+import os
+import sys
+
+from .reviewer import ClaudePRReviewer
+
+
+def main():
+    parser = argparse.ArgumentParser(
+        description="Claude Code PR Review Agent - Analyze pull requests with AI"
+    )
+    parser.add_argument(
+        "--pr",
+        required=True,
+        help="GitHub PR URL (e.g., https://github.com/owner/repo/pull/123)",
+    )
+    parser.add_argument(
+        "--output",
+        "-o",
+        default="review_output.md",
+        help="Output file for the review (default: review_output.md)",
+    )
+    parser.add_argument(
+        "--api-key",
+        default=os.environ.get("ANTHROPIC_API_KEY"),
+        help="Anthropic API key (or set ANTHROPIC_API_KEY env var)",
+    )
+    parser.add_argument(
+        "--github-token",
+        default=os.environ.get("GITHUB_TOKEN"),
+        help="GitHub token for API access (or set GITHUB_TOKEN env var)",
+    )
+
+    args = parser.parse_args()
+
+    if not args.api_key:
+        print("Error: Anthropic API key required. Set ANTHROPIC_API_KEY or use --api-key", file=sys.stderr)
+        sys.exit(1)
+
+    if not args.github_token:
+        print("Error: GitHub token required. Set GITHUB_TOKEN or use --github-token", file=sys.stderr)
+        sys.exit(1)
+
+    reviewer = ClaudePRReviewer(
+        anthropic_api_key=args.api_key,
+        github_token=args.github_token,
+    )
+
+    review = reviewer.review_pr(args.pr)
+
+    with open(args.output, "w") as f:
+        f.write(review)
+
+    print(f"Review saved to {args.output}")
+    print(review)
+
+
+if __name__ == "__main__":
+    main()
--- /dev/null
+++ b/claude-review/reviewer.py
@@ -0,0 +1,195 @@
+"""Core PR review logic using Claude API."""
+
+import json
+import os
+import re
+from dataclasses import dataclass
+from typing import List, Optional
+
+import requests
+
+
+@dataclass
+class PRInfo:
+    owner: str
+    repo: str
+    pull_number: int
+
+
+class ClaudePRReviewer:
+   