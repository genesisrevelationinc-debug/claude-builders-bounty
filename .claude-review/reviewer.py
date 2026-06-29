#!/usr/bin/env python3
"""Claude PR Reviewer - Analyzes PR diffs and generates structured Markdown reviews."""

import argparse
import json
import os
import re
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


class ClaudePRReviewer:
    """Reviews PRs using the Claude API."""

    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key or os.environ.get("ANTHROPIC_API_KEY")
        if not self.api_key:
            raise ValueError("ANTHROPIC_API_KEY must be provided or set as environment variable")
        self.api_url = "https://api.anthropic.com/v1/messages"

    def _call_claude(self, prompt: str, max_tokens: int = 4000) -> str:
        """Call the Claude API with the given prompt."""
        headers = {
            "x-api-key": self.api_key,
            "Content-Type": "application/json",
            "anthropic-version": "2023-06-01",
        }

        payload = {
            "model": "claude-sonnet-4-20250514",
            "max_tokens": max_tokens,
            "messages": [
                {
                    "role": "user",
                    "content": prompt,
                }
            ],
        }

        response = requests.post(self.api_url, headers=headers, json=payload, timeout=120)
        response.raise_for_status()

        data = response.json()
        return data["content"][0]["text"]

    def _build_prompt(self, diff_content: str, pr_url: str) -> str:
        """Build the review prompt for Claude."""
        return f"""You are an expert code reviewer. Analyze the following PR diff and provide a structured review.

PR URL: {pr_url}

Here is the diff:

