#!/usr/bin/env python3

import argparse
import requests
import json
import sys
import os
from urllib.parse import urlparse, parse_qs

def parse_github_pr_url(url):
    """Parse GitHub PR URL to extract owner, repo, and pull request number"""
    parsed = urlparse(url)
    path_parts = parsed.path.strip('/').split('/')
    if len(path_parts) < 3:
        raise ValueError("Invalid GitHub PR URL")
    
    owner = path_parts[0]
    repo = path_parts[1]
    pr_number = path_parts[3] if len(path_parts) > 3 else None
    
    if not pr_number and parsed.query:
        query_params = parse_qs(parsed.query)
        if 'pull' in query_params:
            pr_number = query_params['pull'][0]
    
    return owner, repo, pr_number

def get_pr_diff(owner, repo, pr_number, token=None):
    """Fetch the diff of a pull request from GitHub API"""
    url = f"https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}"
    headers = {
        'Accept': 'application/vnd.github.v3.diff',
        'User-Agent': 'Claude-PR-Reviewer'
    }
    
    if token:
        headers['Authorization'] = f'token {token}'
    
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    return response.text

def analyze_code(diff_text):
    """Analyze code changes and return structured review"""
    # This is a simplified analysis - in a real implementation, 
    # you would integrate with Claude Code API here
    summary = "This pull request includes modifications to improve code quality and add new functionality."
    risks = [
        "Potential performance issues in loops with large datasets",
        "Missing input validation for new API endpoints",
        "Possible security vulnerabilities in authentication logic"
    ]
    suggestions = [
        "Consider adding more unit tests for the new functionality",
        "Review error handling in critical paths",
        "Add input sanitization for user-provided data"
    ]
    
    # Simplified confidence scoring
    confidence = "Medium"
    
    return {
        "summary": summary,
        "risks": risks,
        "suggestions": suggestions,
        "confidence": confidence
    }

def format_markdown_review(analysis):
    """Format the analysis into a structured markdown comment"""
    md = []
    md.append("## Code Review\n")
    md.append(f"**Summary:** {analysis['summary']}\n")
    md.append("### Identified Risks:\n")
    for risk in analysis['risks']:
        md.append(f"- {risk}")
    md.append("\n### Improvement Suggestions:\n")
    for suggestion in analysis['suggestions']:
        md.append(f"- {suggestion}")
    md.append(f"\n**Confidence Score:** {analysis['confidence']}")
    return "\n".join(md)

def main():
    parser = argparse.ArgumentParser(description='Claude Code PR Reviewer')
    parser.add_argument('--pr', required=True, help='GitHub PR URL')
    parser.add_argument('--token', help='GitHub Personal Access Token')
    
    args = parser.parse_args()
    
    try:
        owner, repo, pr_number = parse_github_pr_url(args.pr)
        diff = get_pr_diff(owner, repo, pr_number, args.token)
        analysis = analyze_code(diff)
        markdown_review = format_markdown_review(analysis)
        print(markdown_review)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()