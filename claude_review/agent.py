#!/usr/bin/env python3
"""
Claude PR Review Agent

Analyzes a GitHub PR diff and produces a structured Markdown review comment.

Usage:
    claude-review --pr https://github.com/owner/repo/pull/123
    claude-review --pr https://github.com/owner/repo/pull/123 --output review.md
"""

import argparse
import json
import os
import re
import sys
from dataclasses import dataclass
from typing import List, Optional
from urllib.request import Request, urlopen
from urllib.error import HTTPError


@dataclass
class ReviewResult:
    summary: str
    risks: List[str]
    suggestions: List[str]
    confidence: str  # Low, Medium, High


class GitHubClient:
    def __init__(self, token: Optional[str] = None):
        self.token = token or os.environ.get("GITHUB_TOKEN")
        if not self.token:
            raise ValueError("GitHub token required. Set GITHUB_TOKEN env var or pass --github-token.")

    def _api_request(self, url: str) -> dict:
        headers = {
            "Authorization": f"token {self.token}",
            "Accept": "application/vnd.github.v3+json",
            "User-Agent": "claude-review-agent/1.0",
        }
        req = Request(url, headers=halers)
        with urlopen(req) as response:
            return json.loads(response.read().decode("utf-8"))

    def get_pr_diff(self, owner: str, repo: str, pr_number: int) -> str:
        url = f"https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}"
        # Get diff via raw diff URL
        diff_url = f"https://github.com/{owner}/{repo}/pull/{pr_number}.diff"
        headers = {
            "Authorization": f"token {self.token}",
            "Accept": "application/vnd.github.v3.diff",
            "User-Agent": "claude-review-agent/1.0",
        }
        req = Request(diff_url, headers=headers)
        with urlopen(req) as response:
            return response.read().decode("utf-8")

    def post_comment(self, owner: str, repo: str, pr_number: int, body: str) -> dict:
        url = f"https://api.github.com/repos/{owner}/{repo}/issues/{pr_number}/comments"
        data = json.dumps({"body": body}).encode("utf-8")
        headers = {
            "Authorization": f"token {self.token}",
            "Accept": "application/vnd.github.v3+json",
            "Content-Type": "application/json",
            "User-Agent": "claude-review-agent/1.0",
        }
        req = Request(url, data=data, headers=headers, method="POST")
        with urlopen(req) as response:
            return json.loads(response.read().decode("utf-8"))


class ClaudeClient:
    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key or os.environ.get("ANTHROPIC_API_KEY")
        if not self.api_key:
            raise ValueError("Anthropic API key required. Set ANTHROPIC_API_KEY env var.")

    def review_diff(self, diff_text: str, pr_url: str) -> ReviewResult:
        prompt = self._build_prompt(diff_text, pr_url)

        headers = {
            "x-api-key": self.api_key,
            "anthropic-version": "2023-06-01",
            "Content-Type": "application/json",
        }

        data = {
            "model": "claude-sonnet-4-20250514",
            "max_tokens": 4096,
            "messages": [
                {
                    "role": "user",
                    "content": prompt,
                }
            ],
        }

        req = Request(
            "https://api.anthropic.com/v1/messages",
            data=json.dumps(data).encode("utf-8"),
            headers=headers,
            method="POST",
        )

        with urlopen(req) as response:
            result = json.loads(response.read().decode("utf-8"))
            content = result["content"][0]["text"]
            return self._parse_response(content)

    def _build_prompt(self, diff_text: str, pr_url: str) -> str:
        return f"""You are an expert code reviewer. Analyze the following PR diff and provide a structured review.

PR URL: {pr_url}

Diff:
