#!/usr/bin/env python3

import argparse
import requests
import json
import sys
import os
from typing import List, Dict
import re

def get_github_pr_data(pr_url: str, token: str = None) -> Dict:
    """Fetch PR data from GitHub"""
    # Extract owner, repo, and pr number from URL
    pattern = r"https://github\.com/([^/]+)/([^/]+)/pull/(\d+)"
    match = re.match(pattern, pr_url)
    if not match:
        raise ValueError("Invalid GitHub PR URL")
    
    owner, repo, pr_number = match.groups()
    
    headers = {}
    if token:
        headers['Authorization'] = f'token {token}'
    
    # Fetch PR files data
    api_url = f"https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}/files"
    response = requests.get(api_url, headers=headers)
    response.raise_for_status()
    files_data = response.json()
    
    # Fetch PR details
    api_url = f"https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}"
    response = requests.get(api_url, headers=headers)
    response.raise_for_status()
    pr_data = response.json()
    
    return {
        "files": files_data,
        "pr_info": pr_data
    }

def analyze_code(diff_content: str) -> Dict:
    """Analyze code changes and return structured review"""
    # This is a simplified analysis - in practice, you'd plug in Claude Code here
    # For now, we'll return a mock response
    return {
        "summary": "This is a mock analysis. In a real implementation, Claude Code would analyze the diff and provide insights.",
        "risks": [
            "Potential security vulnerability in authentication logic",
            "Possible performance implications due to nested loop in data processing function"
        ],
        "suggestions": [
            "Consider adding input validation for user-provided parameters",
            "Review error handling for external API calls"
        ],
        "confidence": "Medium"
    }

def format_comment(analysis: Dict) -> str:
    """Format the analysis into a structured Markdown comment"""
    comment = "## Code Review\n\n"
    comment += f"**Summary**: {analysis['summary']}\n\n"
    comment += "### Identified Risks:\n"
    for risk in analysis["risks"]:
        comment += f"- {risk}\n"
    comment += "\n### Improvement Suggestions:\n"
    for suggestion in analysis["suggestions"]:
        comment += f"- {suggestion}\n"
    comment += f"\n**Confidence**: {analysis['confidence']}\n"
    return comment

def main():
    parser = argparse.ArgumentParser(description="Claude Code PR Reviewer")
    parser.add_argument("--pr", required=True, help="GitHub PR URL")
    parser.add_argument("--token", help="GitHub token for API access")
    
    args = parser.parse_args()
    
    try:
        # Fetch PR data
        pr_data = get_github_pr_data(args.pr, args.token)
        
        # Extract diff content
        diff_content = "\n".join([
            file_data.get("patch", "") for file_data in pr_data["files"]
        ])
        
        # Analyze the code
        analysis = analyze_code(diff_content)
        
        # Format and print the comment
        comment = format_comment(analysis)
        print(comment)
        
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()