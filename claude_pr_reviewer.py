#!/usr/bin/env python3

import argparse
import os
import sys
import requests
import json
from typing import Dict, List, Optional

class ClaudePRReviewer:
    def __init__(self, github_token: Optional[str] = None):
        self.github_token = github_token or os.getenv("GITHUB_TOKEN")
        if not self.github_token:
            raise ValueError("GitHub token is required. Set GITHUB_TOKEN environment variable.")
        
    def get_pr_diff(self, pr_url: str) -> str:
        # Extract owner, repo, and PR number from URL
        parts = pr_url.rstrip('/').split('/')
        owner, repo, pr_number = parts[-4], parts[-3], parts[-1]
        
        # Get PR diff from GitHub API
        headers = {
            "Authorization": f"token {self.github_token}",
            "Accept": "application/vnd.github.v3.diff"
        }
        
        response = requests.get(
            f"https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}",
            headers=headers
        )
        response.raise_for_status()
        
        return response.text
    
    def analyze_code(self, diff: str) -> Dict:
        # This is a simplified analysis - in a real implementation, 
        # this would call Claude Code API or similar
        changes_summary = "Code changes have been detected in the pull request."
        risks = []
        suggestions = []
        
        # Simple heuristics for demonstration
        if "password" in diff.lower() or "secret" in diff.lower():
            risks.append("Potential exposure of sensitive information (passwords/secrets)")
            
        if "http://" in diff:
            risks.append("Insecure HTTP URLs detected. Consider using HTTPS.")
            
        if "console.log" in diff or "print(" in diff:
            suggestions.append("Remove debugging statements before merging.")
            
        if "TODO" in diff:
            suggestions.append("Address TODO comments before merging.")
            
        # Add more heuristics here in a real implementation
        
        return {
            "summary": changes_summary,
            "risks": risks,
            "suggestions": suggestions,
            "confidence": "Medium"
        }
    
    def generate_markdown_review(self, analysis: Dict) -> str:
        md = "# Code Review\n\n"
        md += "## Summary of Changes\n"
        md += f"{analysis['summary']}\n\n"
        md += "## Identified Risks\n"
        if analysis['risks']:
            for risk in analysis['risks']:
                md += f"- {risk}\n"
        else:
            md += "- None identified\n"
        md += "\n"
        md += "## Improvement Suggestions\n"
        if analysis['suggestions']:
            for suggestion in analysis['suggestions']:
                md += f"- {suggestion}\n"
        else:
            md = md[:-1] + "- None\n"
        md += "\n"
        md += f"## Confidence\n"
        md += f"{analysis['confidence']}\n"
        return md
    
    def review_pr(self, pr_url: str) -> str:
        diff = self.get_pr_diff(pr_url)
        analysis = self.analyze_code(diff)
        return self.generate_markdown_review(analysis)

def main():
    parser = argparse.ArgumentParser(description="Claude PR Reviewer")
    parser.add_argument("--pr", required=True, help="GitHub PR URL")
    args = parser.parse_args()
    
    try:
        reviewer = ClaudePRReviewer()
        result = reviewer.review_pr(args.pr)
        print(result)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()