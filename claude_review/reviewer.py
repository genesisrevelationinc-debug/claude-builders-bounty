#!/usr/bin/env python3
"""Claude Code PR Review Agent.

Takes a PR diff as input, analyzes it with Claude, and returns a structured
Markdown review comment.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Optional

Prompt = str


@dataclass
class ReviewResult:
    """Structured PR review result."""

    summary: str
    risks: list[str]
    suggestions: list[str]
    confidence: str  # Low, Medium, High

    def to_markdown(self) -> str:
        """Format review as structured Markdown."""
        lines = [
            "## 🤖 Claude Code PR Review",
            "",
            "### Summary",
            "",
            self.summary,
            "",
            "### Identified Risks",
            "",
        ]
        if self.risks:
            for risk in self.risks:
                lines.append(f"- {risk}")
        else:
            lines.append("- No significant risks identified.")
        lines.extend(["", "### Improvement Suggestions", ""])
        if self.suggestions:
            for suggestion in self.suggestions:
                lines.append(f"- {suggestion}")
        else:
            lines.append("- No suggestions at this time.")
        lines.extend([
            "",
            f"### Confidence Score: **{self.confidence}**",
            "",
            "---",
            "*Reviewed by [Claude Code](https://claude.ai)*",
        ])
        return "\n".join(lines)


def _run_claude(prompt: str, api_key: Optional[str] = None) -> str:
    """Run Claude via the Anthropic API using the CLI or direct API call."""
    key = api_key or os.environ.get("ANTHROPIC_API_KEY")
    if not key:
        raise RuntimeError(
            "ANTHROPIC_API_KEY not set. Please set your Anthropic API key."
        )

    # Try using the Anthropic Python SDK first
    try:
        import anthropic

        client = anthropic.Anthropic(api_key=key)
        response = client.messages.create(
            model="claude-sonnet-4-20250514",
            max_tokens=4096,
            messages=[{"role": "user", "content": prompt}],
        )
        return response.content[0].text  # type: ignore[index]
    except ImportError:
        pass

    # Fallback to curl
    result = subprocess.run(
        [
            "curl",
            "-s",
            "https://api.anthropic.com/v1/messages",
            "-H",
            "Content-Type: application/json",
            "-H",
            f"x-api-key: {key}",
            "-H",
            "anthropic-version: 2023-06-01",
            "-d",
            json.dumps(
                {
                    "model": "claude-sonnet-4-20250514",
                    "max_tokens": 4096,
                    "messages": [{"role": "user", "content": prompt}],
                }
            ),
        ],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        raise RuntimeError(f"Claude API call failed: {result.stderr}")

    data = json.loads(result.stdout)
    return data["content"][0]["text"]


def _build_review_prompt(diff: str, pr_url: str) -> Prompt:
    """Build the prompt for Claude to review a PR."""
    return f"""You are an expert code reviewer. Review the following pull request diff and provide a structured analysis.

PR URL: {pr_url}

Here is the diff:

