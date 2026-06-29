"""Core PR review logic using Claude API."""

import os
import re
import sys
from dataclasses import dataclass
from typing import Optional

import requests


@dataclass
class ReviewResult:
    """Structured review output."""
    summary: str
    risks: list[str]
    suggestions: list[str]
    confidence: str
    raw_response: str


class ClaudeReviewer:
    """Claude Code PR Review Agent."""
    
    API_URL = "https://api.anthropic.com/v1/messages"
    
    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key or os.environ.get("ANTHROPIC_API_KEY")
        if not self.api_key:
            raise ValueError("ANTHROPIC_API_KEY is required")
    
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
                    "content": prompt
                }
            ]
        }
        
        response = requests.post(self.API_URL, headers=headers, json=payload, timeout=120)
        response.raise_for_status()
        
        data = response.json()
        return data["content"][0]["text"]
    
    def _build_prompt(self, diff: str, pr_url: Optional[str] = None) -> str:
        """Build the review prompt for Claude."""
        pr_context = f"\nPR URL: {pr_url}" if pr_url else ""
        
        prompt = f"""You are an expert code reviewer. Review the following pull request diff and provide a structured analysis.

## Instructions

Analyze the diff carefully and provide:

1. **Summary**: A concise 2-3 sentence summary of what this PR changes and why.
2. **Risks**: A list of potential risks, bugs, or issues introduced by this PR. Be specific and reference line numbers or files where possible.
3. **Suggestions**: Actionable improvement suggestions for code quality, performance, security, or maintainability.
4. **Confidence Score**: Rate your overall confidence in this PR as Low, Medium, or High based on code quality, test coverage, and potential issues.

## Output Format

Respond in EXACTLY this format (maintain the headers):

### Summary
<2-3 sentence summary>

### Risks
- <risk 1>
- <risk 2>
- ...

### Suggestions
- <suggestion 1>
- <suggestion 2>
- ...

### Confidence
<Low | Medium | High>

## PR Diff{pr_context}

