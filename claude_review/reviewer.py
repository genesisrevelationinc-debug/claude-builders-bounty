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
    """Structured PR review result."""

    summary: str
    risks: list[str]
    suggestions: list[str]
    confidence: str  # Low, Medium, High
    raw_response: str


class ClaudeReviewer:
    """Claude Code PR Review Agent."""

    CLAUDE_API_URL = "https://api.anthropic.com/v1/messages"

    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key or os.environ.get("ANTHROPIC_API_KEY")
        if not self.api_key:
            raise ValueError(
                "Anthropic API key required. Set ANTHROPIC_API_KEY env var."
            )

    def _build_prompt(self, diff: str, pr_url: Optional[str] = None) -> str:
        """Build the prompt for Claude to analyze a PR diff."""
        pr_context = f"\nPR URL: {pr_url}" if pr_url else ""

        prompt = f"""You are an expert code reviewer. Analyze the following PR diff and provide a structured review.

## Instructions

Review the code changes carefully. Focus on:
- Understanding what the PR is trying to accomplish
- Identifying potential bugs, security issues, or edge cases
- Suggesting improvements for code quality, performance, or maintainability
- Assessing the overall quality and risk of the changes

## Output Format

Respond with a JSON object in this exact format:

{{
  "summary": "2-3 sentence summary of what the PR does and its overall quality",
  "risks": [
    "Risk 1 description",
    "Risk 2 description"
  ],
  "suggestions": [
    "Suggestion 1 description",
    "Suggestion 2 description"
  ],
  "confidence": "High"
}}

Confidence must be one of: "Low", "Medium", "High"
- Low: Major concerns, significant risks, or the diff is too large/complex to review confidently
- Medium: Some concerns or areas that need attention, but generally acceptable
- High: Well-structured, clean code with minimal concerns

If there are no risks or suggestions, use empty arrays [].

## PR Diff{pr_context}

