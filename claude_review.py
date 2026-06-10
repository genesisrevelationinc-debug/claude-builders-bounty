#!/usr/bin/env python3

import argparse
pzimport sys
import requests
import json
import os
import openai
from github import Github
import anthropic
import difflib
import re

def get_pr_diff(github_token, repo_name, pr_number):
    """Fetch the PR diff using PyGithub"""
    try:
        g = Github(github_token)
        repo = g.get_repo(repo_name)
        pr = repo.get_pull(int(pr_number))
        return pr.get_commits()[0].get_patch()  # Simplified - in practice would need to get full diff
    except Exception as e:
        print(f"Error fetching PR: {e}")
        return None

def analyze_code_with_claude(diff_text, api_key):
    """Send diff to Claude and get structured analysis"""
    client = anthropic.Anthropic(api_key=api_key)
    
    prompt = f"""
    You are a senior software engineer reviewing a pull request diff.
    
    Please analyze this code diff and provide a structured review in the following format:
    
    ## Summary of Changes
    [2-3 sentences summarizing the main changes]
    
    ## Potential Risks
    - Risk 1
    - Risk 2
    
    ## Improvement Suggestions
    - Suggestion 1
    - Suggestion 2
    
    ## Confidence
    [Low/Medium/High]
    
    Here is the code diff:
    {diff_text}
    """
    
    try:
        response = client.messages.create(
            model="claude-3-opus-20240229",
            max_tokens=1000,
            messages=[{"role": "user", "content": prompt}]
        )
        
        analysis = response.content[0].text
        return analysis
    except Exception as e:
        return f"Error calling Claude: {str(e)}"

def post_comment_to_pr(github_token, repo_name, pr_number, comment_body):
    """Post the comment to the PR"""
    try:
        g = Github(github_token)
        repo = g.get_repo(repo_name)
        pr = repo.get_pull(int(pr_number))
        pr.create_issue_comment(comment_body)
        print("Successfully posted comment to PR")
    except Exception as e:
        print(f"Error posting comment: {e}")

def main():
    parser = argparse.ArgumentParser(description='Claude PR Reviewer')
    parser.add_argument('--pr', required=True, help='GitHub PR URL')
    parser.add_argument('--claude-key', required=True, help='Claude API key')
    parser.add_argument('--github-token', required=True, help='GitHub token')
    
    args = parser.parse_args()
    
    # Extract owner, repo, and PR number from URL
    pr_url = args.pr
    claude_key = args.claude_key
    github_token = args.github_token
    
    # Simple URL parsing (in real implementation, use regex)
    if "github.com/" in pr_url:
        # Format: https://github.com/owner/repo/pull/123
        parts = pr_url.split("/")
        owner = parts[3]
        repo_name = parts[4]
        pr_number = parts[6]
        repo_full_name = f"{owner}/{repo_name}"
    else:
        print("Invalid PR URL format")
        return
    
    # Get the diff
    diff = get_pr_diff(github_token, repo_full_name, pr_number)
    if not diff:
        print("Failed to get PR diff")
        return
    
    # Analyze with Claude
    analysis = analyze_code_with_claude(diff, claude_key)
    
    # Post the analysis as a comment
    post_comment_to_pr(github_token, repo_full_name, pr_number, analysis)
    
    # Also print to stdout
    print(analysis)

if __name__ == "__main__":
    main()