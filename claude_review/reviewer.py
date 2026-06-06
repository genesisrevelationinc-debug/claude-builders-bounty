#!/usr/bin/env python3
"""Claude Code PR Review Agent.

Takes a PR diff as input, analyzes it with Claude, and returns a
structured Markdown review comment.
"""

from __future__ import annotations

import argparse
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
    """Structured PR review result."""

    summary: str
    risks: list[str]
    suggestions: list[str]
    confidence: str


def get_pr_diff(pr_url: str, github_token: Optional[str] = None) -> str:
    """Fetch the PR diff from GitHub."""
    # Parse PR URL to get owner, repo, and PR number
    match = re.match(r"https://github\.com/([^/]+)/([^/]+)/pull/(\d+)", pr_url)
    if not match:
        raise ValueError(f"Invalid PR URL: {pr_url}")

    owner, repo, pr_number = match.groups()

    # Use GitHub API to get the diff
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


def get_pr_info(pr_url: str, github_token: Optional[str] = None) -> dict:
    """Fetch PR metadata from GitHub API."""
    match = re.match(r"https://github\.com/([^/]+)/([^/]+)/pull/(\d+)", pr_url)
    if not match:
        raise ValueError(f"Invalid PR URL: {pr_url}")

    owner, repo, pr_number = match.groups()

    headers = {
        "Accept": "application/vnd.github.v3+json",
        "User-Agent": "claude-review/0.1.0",
    }

    if github_token:
        headers["Authorization"] = f"token {github_token}"

    api_url = f"https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}"

    response = requests.get(api_url, headers=headers, timeout=30)
    response.raise_for_status()

    return response.json()


def call_claude_api(diff: str, pr_info: dict, api_key: Optional[str] = None) -> ReviewResult:
    """Call Claude API to analyze the PR diff."""
    api_key = api_key or os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        raise ValueError("ANTHROPIC_API_KEY not set")

    # Truncate diff if too long (Claude has context limits)
    max_diff_chars = 100000
    if len(diff) > max_diff_chars:
        diff = diff[:max_diff_chars] + "\n\n[... diff truncated due to length ...]"

    pr_title = pr_info.get("title", "Unknown")
    pr_body = pr_info.get("body", "") or ""

    prompt = f"""You are an expert code reviewer. Analyze the following pull request and provide a structured review.

PR Title: {pr_title}
PR Description: {pr_body}

Here is the diff:

