#!/usr/bin/env python3
"""
Claude Code PR Reviewer Agent
Reviews GitHub PRs and generates structured Markdown comments.
"""

import argparse
import os
import requests
import sys
import json
import re
import openai  # Using Claude via OpenAI-compatible API

from github import Github


def fetch_pr_diff(repo_url, pr_number, github_token):
    """Fetch the diff of a pull request."""
    # Extract owner/repo from URL
    # e.g., https://github.com/owner/repo/pull/123
    match = re.search(r"github\.com/([^/]+)/([^/]+)/pull/(\d+)", repo_url)
    if not match:
        raise ValueError("Invalid GitHub PR URL")
    
    owner = match.group(1)
    repo_name = match.group(2)
    pr_num = int(match.group(3))
    
    g = Github(github_token)
    repo = g.get_repo(f"{owner}/{repo_name}")
    pr = repo.get_pull(pr_num)
    
    # Get files and collect diff
    files = pr.get_files()
    diff_text = ""
    for f in files:
        if f.patch:
            diff_text += f.patch + "\n"
    
    return diff_text


def analyze_diff_with_claude(diff_text, claude_api_key):
    """Send diff to Claude and get structured review."""
    prompt = f"""
You are a senior software engineer reviewing a pull request.
Analyze the following code diff and provide a structured review in Markdown:

{diff_text}

Please respond with this exact format:
# PR Review Summary

## Summary of Changes
[2-3 sentences summarizing the changes]

## Identified Risks
- [List] Risks identified in the code changes

## Improvement Suggestions
- [List] Actionable suggestions for improvement

## Confidence Score
[Low/Medium/High - pick one]
"""
    
    # Using OpenAI API format for Claude API
    headers = {
        "Authorization": f"Bearer {claude_api_key}",
        "Content-Type": "application/json"
    }
    
    data = {
        "model": "claude-3-haiku",  # or claude-3-opus, claude-3-sonnet
        "messages": [
            {"role": "user", "content": prompt}
        ],
        "max_tokens": 1000
    }
    
    response = requests.post(
        "https://api.anthropic.com/v1/messages",
        headers=headers,
        json=data
    )
    
    if response.status_code != 200:
        raise Exception(f"Claude API error: {response.text}")
    
    result = response.json()
    return result['content'][0]['text']


def main():
    parser = argparse.ArgumentParser(description="Claude Code PR Reviewer")
    parser.add_argument("--pr", required=True, help="GitHub PR URL")
    parser.add_argument("--github-token", required=True, help="GitHub Personal Access Token")
    parser.add_argument("--claude-key", required=True, help="Claude API Key")
    
    args = parser.parse_args()
    
    try:
        # Fetch PR diff
        diff = fetch_pr_diff(args.pr, 0, args.github_token)  # pr_number is parsed from URL
        
        # Get review from Claude
        review = analyze_diff_with_claude(diff, args.claude_key)
        
        print(review)
        
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()