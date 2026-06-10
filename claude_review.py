#!/usr/bin/env python3
"""
Claude Code PR Reviewer Agent
CLI tool to review GitHub PRs and generate structured feedback
"""

import argparse
import requests
import json
import re
import os
import sys
from typing import Dict, List, Optional
import urllib.parse

class PRReviewer:
    def __init__(self, github_token: Optional[str] = None):
        self.github_token = github_token
        self.headers = {
            'Accept': 'application/vnd.github.v3+json',
            'User-Agent': 'Claude-Code-Reviewer'
        }
        if github_token:
            self.headers['Authorization'] = f'token {github_token}'
    
    def parse_pr_url(self, pr_url: str) -> tuple:
        """Parse GitHub PR URL into owner, repo, and PR number"""
        # Handle different URL formats
        patterns = [
            r'https://github\.com/([^/]+)/([^/]+)/pull/(\d+)',
            r'https://github\.com/([^/]+)/([^/]+)/pulls/(\d+)',
        ]
        
        for pattern in patterns:
            match = re.match(pattern, pr_url)
            if match:
                owner, repo, pr_number = match.groups()
                return owner, repo, int(pr_number)
        
        raise ValueError("Invalid PR URL format")
    
    def get_pr_data(self, owner: str, repo: str, pr_number: int) -> Dict:
        """Fetch PR data from GitHub API"""
        api_url = f"https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}"
        
        response = requests.get(api_url, headers=self.headers)
        response.raise_for_status()
        return response.json()
    
    def get_pr_files(self, owner: str, repo: str, pr_number: int) -> List[Dict]:
        """Fetch PR files data from GitHub API"""
        api_url = f"https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}/files"
        
        response = requests.get(api_url, headers=self.headers)
        response.raise_for_status()
        return response.json()
    
    def analyze_changes(self, files_data: List[Dict]) -> Dict[str, any]:
        """Analyze the changes in the PR files"""
        changes_summary = []
        file_changes = {}
        
        # Collect summary of all file changes
        for file in files_data:
            filename = file['filename']
            status = file['status']
            additions = file['additions']
            deletions = file['deletions']
            
            file_changes[filename] = {
                'status': status,
                'additions': additions,
                'de deletions': deletions,
                'changes': file.get('changes', [])
            }
            
            changes_summary.append(f"File {filename} {status} with {additions} additions and {deletions} deletions")
        
        return {
            'summary': changes_summary,
            'file_changes': file_changes
        }
    
    def generate_review(self, analysis: Dict) -> str:
        """Generate structured markdown review"""
        # This is a simplified implementation
        # In a real implementation, Claude Code would analyze the content more deeply
        changes_summary = "\n".join(analysis['summary'][:3])  # First 3 changes for summary
        
        summary = f"## Summary of Changes\n\nThis PR modifies {len(analysis['summary'])} files. {changes_summary}"
        
        risks = [
            "Potential breaking changes in core logic",
            "Security implications of new dependencies",
            "Performance impact of algorithm changes"
        ]
        
        suggestions = [
            "Add unit tests for new functionality",
            "Consider adding more detailed documentation",
            "Review error handling in modified functions"
        ]
        
        confidence = "Medium"
        
        return f"""{summary}
## Identified Risks
- {'\n- '.join(risks)}
## Improvement Suggestions
- {'\n- '.join(suggestions)}
## Confidence Score: {confidence}
"""
    
    def review_pr(self, pr_url: str) -> str:
        """Main function to review a PR and return structured feedback"""
        try:
            owner, repo, pr_number = self.parse_pr_url(pr_url)
            pr_data = self.get_pr_data(owner, repo, pr_number)
            files_data = self.get_pr_files(owner, repo, pr_number)
            analysis = self.analyze_changes(files_data)
            return self.generate_review(analysis)
        except Exception as e:
            return f"Error reviewing PR: {str(e)}"

def main():
    parser = argparse.ArgumentParser(description='Review a GitHub PR with structured feedback')
    parser.add_argument('--pr', required=True, help='GitHub PR URL to review')
    parser.add_argument('--token', help='GitHub token for API access')
    
    args = parser.parse_args()
    
    reviewer = PRReviewer(args.token)
    review = reviewer.review_pr(args.pr)
    print(review)

if __name__ == "__main__":
    main()