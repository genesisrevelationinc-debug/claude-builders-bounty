"""Core review logic for the Claude PR Review agent."""

import json
import os
import re
import subprocess
import sys
from dataclasses import dataclass
from typing import Optional

import requests


@dataclass
class ReviewResult:
    """Structured review result."""

    summary: str
    risks: list[str]
    suggestions: list[str]
    confidence: str
    raw_response: str


class ClaudeReviewer:
    """Claude-powered PR reviewer."""

    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key or os.environ.get("ANTHROPIC_API_KEY")
        if not self.api_key:
            raise ValueError(
                "ANTHROPIC_API_KEY must be provided or set as environment variable"
            )
        self.api_url = "https://api.anthropic.com/v1/messages"

    def fetch_pr_diff(self, pr_url: str) -> str:
        """Fetch PR diff from GitHub."""
        # Extract owner, repo, and PR number from URL
        match = re.match(r"https://github\.com/([^/]+)/([^/]+)/pull/(\d+)", pr_url)
        if not match:
            raise ValueError(f"Invalid PR URL: {pr_url}")

        owner, repo, pr_number = match.groups()

        # Try to get diff using gh CLI if available
        try:
            result = subprocess.run(
                ["gh", "pr", "view", pr_url, "--json", "diff"],
                capture_output=True,
                text=True,
                check=True,
            )
            data = json.loads(result.stdout)
            if "diff" in data and data["diff"]:
                return data["diff"]
        except (subprocess.CalledProcessError, FileNotFoundError, json.JSONDecodeError):
            pass

        # Fallback to GitHub API
        github_token = os.environ.get("GITHUB_TOKEN")
        headers = {
            "Accept": "application/vnd.github.v3.diff",
            "User-Agent": "claude-review/0.1.0",
        }
        if github_token:
            headers["Authorization"] = f"token {github_token}"

        api_url = f"https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}"
        response = requests.get(api_url, headers=headers, timeout=30)
        response.raise_for_status()

        return response.text

    def _build_prompt(self, diff: str) -> str:
        """Build the prompt for Claude."""
        return f"""You are an expert code reviewer. Analyze the following PR diff and provide a structured review.

Please respond in the following format:

SUMMARY:
[2-3 sentence summary of the changes]

RISKS:
- [risk 1]
- [risk 2]
...

SUGGESTIONS:
- [suggestion 1]
- [suggestion 2]
...

CONFIDENCE: [Low/Medium/High]

Here is the PR diff to analyze:

