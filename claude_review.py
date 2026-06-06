#!/usr/bin/env python3

import argparse
import requests
import json
import sys
import os
from typing import Dict, List, Tuple
import re

class ClaudeCodeReviewer:
    def __init__(self, github_token: str = None):
        self.github_token = github_token
        self.headers = {
            "Accept": "application/vnd.github.v3+json"
        }
        if github_token:
            self.headers["Authorization"] = f"token {github_token}"
    
    def get_pr_diff(self, repo_owner: str, repo_name: str, pr_number: int) -> str:
        """Fetch the diff of a PR from GitHub"""
        url = f"https://api.github.com/repos/{repo_owner}/{repo_name}/pulls/{pr_number}"
        response = requests.get(url, headers=self.headers)
        response.raise_for_status()
        pr_data = response.json()
        diff_url = pr_data.get("diff_url")
        
        if not diff_url:
            raise ValueError("Could not get diff URL from PR")
        
        diff_response = requests.get(diff_url, headers=self.headers)
        diff_response.raise_for_status()
        return diff_response.text
    
    def analyze_code(self, diff_content: str) -> Dict:
        """Analyze the code changes and return structured feedback"""
        # In a real implementation, this would use Claude Code to analyze the changes
        # For this bounty, we're simulating the structure
        return self._generate_mock_analysis(diff_content)
    
    def _generate_mock_analysis(self, diff: str) -> Dict:
        """Generate mock analysis (in practice, this would be replaced with Claude Code analysis)"""
        # This is a simplified mock - in practice, Claude Code would analyze the diff
        changes_summary = "This pull request modifies several files in the codebase, primarily focusing on updating the user authentication module and related tests."
        
        risks = [
            "Potential security vulnerability in the new authentication implementation",
            "Missing input validation in form processing logic"
        ]
        
        suggestions = [
            "Add input validation for all user-provided fields",
            "Implement proper error handling for database connections",
            "Add unit tests for the new utility functions"
        ]
        
        return {
            "summary": changes_summary,
            "risks": risks,
            "suggestions": suggestions,
            "confidence": "Medium"
        }
    
    def format_output(self, analysis: Dict) -> str:
        """Format the analysis into structured Markdown"""
        output = []
        output.append("## Code Review\n")
        output.append(f"**Summary of Changes:**\n{analysis['summary']}\n")
        output.append("### Identified Risks\n")
        for i, risk in enumerate(analysis['risks'], 1):
            output.append(f"{i}. {risk}")
        output.append("\n### Improvement Suggestions\n")
        for i, suggestion in enumerate(analysis['suggestions'], 1):
            output.append(f"{i}. {suggestion}")
        output.append(f"\n### Confidence: {analysis['confidence']}\n")
        return "\n".join(output)
    
    def parse_github_url(self, url: str) -> Tuple[str, str, int]:
        """Parse GitHub PR URL into (owner, repo, pr_number)"""
        # Pattern to match URLs like: https://github.com/owner/repo/pull/123
        pattern = r"https://github.com/([^/]+)/([^/]+)/pull/(\d+)"
        match = re.match(pattern, url)
        if not match:
            raise ValueError("Invalid GitHub PR URL")
        owner, repo, pr_number = match.groups()
        return (owner, repo, int(pr_number))

def main():
    parser = argparse.ArgumentParser(description="Claude Code PR Reviewer")
    parser.add_argument("--pr", required=True, help="GitHub PR URL")
    parser.add_argument("--token", help="GitHub token for API access")
    
    args = parser.parse_args()
    
    try:
        owner, repo, pr_number = ClaudeCodeReviewer().parse_github_url(args.pr)
    except ValueError as e:
        print(f"Error parsing URL: {e}")
        sys.exit(1)
    
    reviewer = ClaudeCodeReviewer(args.token)
    
    try:
        diff_content = reviewer.get_pr_diff(owner, repo, pr_number)
        analysis = reviewer.analyze_code(diff_content)
        print(reviewer.format_output(analysis))
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()