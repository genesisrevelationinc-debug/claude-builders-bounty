"""Core PR review logic using Claude API."""

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
    confidence: str  # Low, Medium, High
    raw_response: str


class ClaudeReviewer:
    """Reviews PR diffs using Claude API and produces structured Markdown output."""
    
    API_URL = "https://api.anthropic.com/v1/messages"
    MODEL = "claude-3-5-sonnet-20241022"
    
    SYSTEM_PROMPT = """You are an expert code reviewer. Analyze the provided PR diff and produce a structured review.

Respond ONLY with a JSON object in this exact format:
{
    "summary": "2-3 sentence summary of the changes",
    "risks": ["risk 1", "risk 2", ...],
    "suggestions": ["suggestion 1", "suggestion 2", ...],
    "confidence": "High" | "Medium" | "Low"
}

Guidelines:
- Summary: Concise overview of what the PR does and its intent
- Risks: List of potential issues, bugs, security concerns, or architectural problems. Empty list if none found.
- Suggestions: Actionable improvements for code quality, performance, readability, or maintainability. Empty list if none.
- Confidence: Your certainty about the review quality given the diff context. Use "Low" if the diff is very large or lacks context, "Medium" for typical PRs, "High" when you have strong confidence.

Be thorough but concise. Focus on substantive issues over style nits."""

    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key or os.environ.get("ANTHROPIC_API_KEY")
        if not self.api_key:
            raise ValueError("ANTHROPIC_API_KEY must be provided or set as environment variable")
    
    def _fetch_pr_diff(self, pr_url: str) -> str:
        """Fetch PR diff from GitHub API."""
        # Extract owner, repo, PR number from URL
        match = re.match(r'https?://github\.com/([^/]+)/([^/]+)/pull/(\d+)', pr_url)
        if not match:
            raise ValueError(f"Invalid PR URL: {pr_url}")
        
        owner, repo, pr_number = match.groups()
        
        # Try to get token from env
        token = os.environ.get("GITHUB_TOKEN")
        headers = {
            "Accept": "application/vnd.github.v3.diff",
            "User-Agent": "claude-review/0.1.0"
        }
        if token:
            headers["Authorization"] = f"token {token}"
        
        api_url = f"https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}"
        
        response = requests.get(api_url, headers=headers, timeout=30)
        response.raise_for_status()
        
        # GitHub API returns diff directly when Accept header is set
        if "diff" in response.headers.get("Content-Type", ""):
            return response.text
        
        # Fallback: fetch diff URL
        diff_url = response.json().get("diff_url")
        if diff_url:
            diff_response = requests.get(diff_url, headers=headers, timeout=30)
            diff_response.raise_for_status()
            return diff_response.text
        
        raise ValueError("Could not fetch PR diff")
    
    def _call_claude(self, diff_content: str) -> ReviewResult:
        """Send diff to Claude API and parse response."""
        # Truncate very large diffs
        max_chars = 150000  # ~ Claude's context limit allowance
        if len(diff_content) > max_chars:
            diff_content = diff_content[:max_chars] + "\n\n[... diff truncated due to size ...]"
        
        user_message = f"Please review the following PR diff:\n\n