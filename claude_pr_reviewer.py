#!/usr/bin/env python3
import openai
import requests
import argparse
from urllib.parse import urlparse
import os
import json
import sys

def get_pr_diff(owner, repo, pr_number, token):
    """Fetch the diff of a pull request from GitHub"""
    url = f"https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}"
    
    headers = {
        'Authorization': f'token {token}' if token else None,
        'Accept': 'application/vnd.github.v3.diff'
    }
    
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return response.text
    else:
        raise Exception(f"Failed to fetch PR diff: {response.status_code} {response.text}")

def analyze_code_with_claude(diff_text):
    """Analyze the code diff using Claude Code"""
    # This is a simplified version - in practice, you would call Claude Code API here
    # For now, we'll return a mock response
    return {
        "summary": "Code changes have been reviewed.",
        "risks": ["Potential SQL injection in user authentication", "Missing input validation"],
        "suggestions": ["Add input sanitization", "Implement proper error handling"],
        "confidence": "Medium"
    }

def format_comment(analysis):
    """Format the analysis results into a structured markdown comment"""
    comment = f"""## Summary
{analysis['summary']}

## Risks
{chr(10).join(f"- {risk}" for risk in analysis['risks'])}

## Suggestions
{chr(10).join(f"- {suggestion}" for suggestion in analysis['suggestions'])}

## Confidence
{analysis['confidence']}
"""
    return comment

def main():
    parser = argparse.ArgumentParser(description="Claude PR Reviewer")
    parser.add_argument('--pr', required=True, help='GitHub PR URL')
    args = parser.parse_args()

    # Parse the PR URL
    parsed_url = urlparse(args.pr)
    path_parts = parsed_url.path.strip("/").split("/")
    if len(path_parts) < 4:
        print("Invalid PR URL")
        return
    
    owner = path_parts[1]
    repo = path_parts[2]
    pr_number = path_parts[3]
    
    # Get GitHub token from environment variable
    token = os.environ.get("GITHUB_TOKEN")
    
    try:
        diff = get_pr_diff(owner, repo, pr_number, token)
        analysis = analyze_code_with_cla