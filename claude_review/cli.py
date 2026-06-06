import argparse
import sys
import requests
import json
from typing import Dict, Any


def get_pr_info(pr_url: str) -> Dict[str, Any]:
    """Extract owner, repo, and pull request number from URL"""
    # Simple parsing - in practice you might want to use a more robust URL parser
    parts = pr_url.strip('/').split('/')
    if len(parts) >= 2:
        return {
            'owner': parts[-4],
            'repo': parts[-3],
            'pr_number': parts[-1]
        }
    raise ValueError("Invalid PR URL format")


def fetch_pr_diff(owner: str, repo: str, pr_number: int) -> str:
    """Fetch the diff of a pull request"""
    url = f"https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}"
    
    response = requests.get(
        url,
        headers={
            'Accept': 'application/vnd.github.v3.diff'
        }
    )
    
    if response.status_code == 200:
        return response.text
    else:
        response.raise_for_status()


def analyze_code(diff: str) -> Dict[str, Any]:
    """Analyze the code diff and return structured feedback"""
    # This is where you would integrate with an AI model like Claude
    # For now, we'll return mock data
    return {
        "summary": "This PR adds new functionality to handle user authentication. It includes changes to the login flow and introduces a new session management module.",
        "risks": [
            "Potential security vulnerability in authentication logic",
            "Missing input validation on session timeout values"
        ],
        "suggestions": [
            "Add additional validation for user inputs in login form",
            "Consider adding rate limiting to authentication endpoints"
        ],
        "confidence": "Medium"
    }


def format_comment(analysis: Dict[str, Any]) -> str:
    """Format the analysis into a structured markdown comment"""
    comment = f"""## Code Review Analysis
### Summary
{analysis['summary']}
### Identified Risks
"""
    for risk in analysis['risks']:
        comment += f"- {risk}
"

    comment += """
### Improvement Suggestions
"""
    for suggestion in analysis['suggestions']:
        comment += f"- {suggestion}
"

    comment += f"""
### Confidence Level
{analysis['confidence']}
"""
    
    return comment


def main():
    parser = argparse.ArgumentParser(description='Review a GitHub PR with Claude')
    parser.add_argument('--pr', required=True, help='URL of the PR to review')
    
    args = parser.parse_args()
    
    try:
        pr_info = get_pr_info(args.pr)
        diff = fetch_pr_diff(pr_info['owner'], pr_info['repo'], pr_info['pr_number'])
        analysis = analyze_code(diff)
        comment = format_comment(analysis)
        print(comment)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()