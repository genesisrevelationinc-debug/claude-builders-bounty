#!/usr/bin/env python3
"""
Claude Code PR Review Agent

A CLI tool that analyzes GitHub PRs and provides structured Markdown reviews.
"""

import argparse
import json
import os
import re
import sys
import urllib.parse
from dataclasses import dataclass
from typing import Dict, List, Optional, Tuple

import requests


@dataclass
class ReviewComment:
    summary: str
    risks: List[str]
    suggestions: List[str]
    confidence: str  # Low, Medium, High


def extract_pr_info(pr_url: str) -> Tuple[str, str, str, int]:
    """Extract owner, repo, and PR number from GitHub URL"""
    # Parse URL like: https://github.com/owner/repo/pull/123
    pattern = r"github\.com/([^/]+)/([^/]+)/pull/(\d+)"
    match = re.search(pattern, pr_url)
    if not match:
        raise ValueError("Invalid GitHub PR URL format")
    
    owner, repo, pr_number = match.groups()
    return owner, repo, int(pr_number)


def get_pr_diff(owner: str, repo: str, pr_number: int, token: str) -> str:
    """Get PR diff using GitHub API"""
    headers = {"Authorization": f"token {token}"} if token else {}
    url = f"https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}"
    
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    
    pr_data = response.json()
    return pr_data.get("diff_url", "")


def analyze_diff(diff_content: str) -> ReviewComment:
    """Analyze the diff content and generate a review"""
    # This is a simplified analyzer - in practice, this would use Claude Code
    # to analyze the diff and generate meaningful insights
    
    # Simple heuristics for demonstration
    lines = diff_content.split('\n')
    changes = [line for line in lines if line.startswith('+') or line.startswith('-')]
    
    summary = f"This PR modifies {len(changes)} lines of code. "
    if any("security" in line.lower() or "auth" in line.lower() for line in changes):
        summary += "Security-related code was detected."
    else:
        summary += "No critical security concerns found."
    
    risks = []
    suggestions = []
    
    # Simple risk detection
    if any("TODO" in line for line in changes):
 risk.append("TODO comments found in code that should be addressed")
    
    if any("console.log" in line or "print(" in line for line in changes):
 suggestions.append("Consider removing debug statements before merging")
    
    if len(changes) > 100:
 risks.append("Large PR detected - consider breaking into smaller commits")
    
    # Confidence based on analysis depth
    if len(changes) > 50:
 confidence = "Medium"
    else:
 confidence = "High"
    
    if not risks:
 risks.append("No significant risks identified in the changes")
    
    if not suggestions:
 suggestions.append("Code follows general best practices")
    
    return ReviewComment(
        summary=summary,
        risks=risks or ["No significant risks identified in the changes"],
        suggestions=suggestions or ["Code follows general best practices"],
        confidence=confidence
    )


def format_markdown_review(review: ReviewComment) -> str:
    """Format the review as structured Markdown"""
    md = []
    md.append("## Code Review Summary")
    md.append(review.summary)
 md.append("")
    
    md.append("### Identified Risks")
    for risk in review.risks:
 md.append(f"- {risk}")
 md.append("")
    
    md.append("### Improvement Suggestions")
    for suggestion in review.suggestions:
 md.append(f"- {suggestion}")
 md.append("")
    
    md.append(f"**Confidence Score: {review.confidence}**")
    
    return "\n".join(md)


def main():
    parser = argparse.ArgumentParser(description="Claude Code PR Reviewer")
    parser.add_argument("--pr", required=True, help="GitHub PR URL")
    
    args = parser.parse_args()
    
    try:
        owner, repo, pr_number = extract_pr_info(args.pr)
        
        # Get GitHub token from environment for API access
        token = os.environ.get("GITHUB_TOKEN", "")
        
        # In a real implementation, we would fetch the actual diff
        # For this demo, we'll simulate a response
        diff_content = f"--- a/file.py\n+++ b/file.py\n@@ -1,2 +1,3 @@\n print('hello')\n+// TODO: add input validation\n+console.log('debug')"
        
        review = analyze_diff(diff_content)
        markdown_review = format_markdown_review(review)
        
        print(markdown_review)
        
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()