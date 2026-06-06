#!/usr/bin/env python3
"""
Claude Code PR Reviewer Agent
CLI tool that analyzes PR diffs and generates structured Markdown reviews.
"""

import argparse
import os
import sys
from typing import Optional
import requests
import openai
from github import Github
import json
import re


def get_pr_diff(github_token: str, pr_url: str) -> str:
    """Fetch the diff content of a PR using the GitHub API."""
    # Extract owner, repo, and pr number from URL
    pattern = r"github\.com/([^/]+)/([^/]+)/pull/(\d+)"
    match = re.search(pattern, pr_url)
    if not match:
        raise ValueError("Invalid PR URL")
    
    owner, repo_name, pr_number = match.groups()
    pr_number = int(pr_number)
    
    # Initialize GitHub client
    g = Github(github_token)
    repo = g.get_repo(f"{owner}/{repo_name}")
    pr = repo.get_pull(pr_number)
    
    return pr.diff_url.replace("/diff", "") # Return raw diff URL


def analyze_code_with_claude(diff_content: str, api_key: str) -> dict:
    """Analyze code using Claude Code API."""
    prompt = f"""Analyze the following GitHub PR diff and provide a code review:

<diff>
{diff_content}
</diff>

Please provide your response in the following structured format:
<review>
<summary>
2-3 sentences summarizing the changes
</summary>

<risks>
List of identified risks (3-5 items)
</risks>

<suggestions>
List of improvement suggestions (3-5 items)
</suggestions>

<confidence>
Confidence score: Low / Medium / High
</confidence>
</review>"""

    # In a real implementation, this would call Claude Code API
    # For the purpose of this example, we'll simulate a response
    return {
        "summary": "This PR introduces new authentication middleware and updates the user model. Key changes include adding JWT-based authentication and updating user schema.",
        "risks": [
            "Input validation is missing for new fields",
            "Potential N+1 query issues in the user retrieval",
            "Hardcoded secrets in configuration files"
        ],
        "suggestions": [
            "Add input sanitization for user inputs",
            "Consider using environment variables for secrets",
            "Add unit tests for the new authentication flow"
        ],
        "confidence": "Medium"
    }


def format_markdown_review(analysis: dict) -> str:
    """Format the analysis result into structured Markdown."""
    risks_md = "\n".join([f"- {risk}" for risk in analysis["risks"]])
    suggestions_md = "\n".join([f"- {suggestion}" for suggestion in analysis["suggestions"]])
    
    return f"""## Summary
{analysis['summary']}

## Risks
{risks_md}

## Suggestions
{suggestions_md}

## Confidence: {analysis['confidence']}
"""


def main():
    parser = argparse.ArgumentParser(description="Claude Code PR Reviewer")
    parser.add_argument("--pr", help="GitHub PR URL", required=True)
    parser.add_argument("--github-token", help="GitHub API token", required=True)
    parser.add_argument("--claude-api-key", help="Claude Code API key", required=True)
    
    args = parser.parse_args()
    
    # Get PR diff
    try:
        diff_content = get_pr_diff(args.github_token, args.pr)
    except Exception as e:
        print(f"Error fetching PR diff: {e}", file=sys.stderr)
        sys.exit(1)
    
    # Analyze with Claude Code
    analysis = analyze_code_with_claude(diff_content, args.claude_api_key)
    
    # Format and print the review
    review = format_markdown_review(analysis)
    print(review)


if __name__ == "__main__":
    main()