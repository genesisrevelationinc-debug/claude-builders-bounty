#!/usr/bin/env python3
"""Claude Code PR Review Agent.

Takes a PR diff as input, analyzes it with Claude, and returns
a structured Markdown review comment.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
import urllib.parse
from pathlib import Path

try:
    import requests
except ImportError:
    requests = None  # type: ignore


def fetch_pr_diff(pr_url: str, github_token: str | None = None) -> str:
    """Fetch the diff for a GitHub PR URL."""
    # Convert PR URL to diff URL
    # https://github.com/owner/repo/pull/123 -> https://github.com/owner/repo/pull/123.diff
    diff_url = pr_url.rstrip("/") + ".diff"

    headers: dict[str, str] = {
        "Accept": "application/vnd.github.v3.diff",
    }
    if github_token:
        headers["Authorization"] = f"token {github_token}"

    response = requests.get(diff_url, headers=headers, timeout=30)
    response.raise_for_status()
    return response.text


def call_claude_api(diff_text: str, api_key: str | None = None) -> str:
    """Call the Anthropic Claude API to analyze the diff."""
    api_key = api_key or os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        raise ValueError(
            "ANTHROPIC_API_KEY environment variable must be set. "
            "Get one at https://console.anthropic.com/"
        )

    prompt = f"""You are an expert code reviewer. Analyze the following PR diff and provide a structured review.

Please respond in the following format (Markdown):

## 🔍 PR Review

### Summary
[2-3 sentence summary of what the PR does]

### Identified Risks
- [Risk 1]
- [Risk 2]
- ...

### Improvement Suggestions
- [Suggestion 1]
- [Suggestion 2]
- ...

### Confidence Score
**Confidence: [Low/Medium/High]**

Rules:
- Be concise but thorough
- Focus on code quality, security, performance, and maintainability
- If the diff is too large to review fully, note that limitation
- If you see no significant issues, say so clearly
- The confidence score reflects how certain you are about your assessment

Here is the diff to review:

