#!/usr/bin/env python3
import argparse
import json
import os
import subprocess
import sys
import tempfile
import requests

def get_github_token():
    """Get GitHub token from env var or error message"""
    token = os.environ.get('GITHUB_TOKEN')
    if not token:
        print("Error: GITHUB_TOKEN not set in environment variables")
        sys.exit(1)
    return token

def get_pr_details(pr_url):
    """Get PR owner, repo, and PR number from URL"""
    parts = pr_url.rstrip('/').split('/')
    owner = parts[-3]  # e.g. github.com/owner/repo/pulls/1 -> owner
    repo = parts[-2]   # e.g. github.com/owner/repo/pulls/1 -> repo
    pr_number = parts[-1]  # e.g. github.com/owner/repo/pulls/1 -> 1
    return owner, repo, pr_number

def setup_claude_review():
    """Main function to setup the PR review tool"""
    print("Setting up Claude Code PR review environment...")
    return {
        'name': 'claude-review',
        'version': '1.0.0'
    }

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--pr', required=True, 
                      help='URL of the PR to review')
    parser.add_argument('