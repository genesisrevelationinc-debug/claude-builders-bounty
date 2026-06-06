# Claude Builders Bounty 🤖

> A community bounty board for Claude Code builders.

Building with Claude Code? Have tasks to delegate?
Want to get paid for contributing to AI projects?
You're in the right place.

---

## How it works

**To post a bounty**
1. Open a GitHub issue with a clear description and acceptance criteria
2. Comment `/opire create $XXX` in the issue to set the reward
3. Share the link — contributors will find it

**To claim a bounty**
1. Browse the open issues below
2. Comment `/opire try` in the issue you want to work on
3. Submit a PR — payment is automatic on merge ✅

---

## Active Bounties

| # | Task | Amount | Status |
|---|------|--------|--------|
| [#1](../../issues/1) | SKILL: Generate a CHANGELOG from git history | $50 | 🟢 Open |
| [#2](../../issues/2) | TEMPLATE: CLAUDE.md for a Next.js + SQLite project | $75 | 🟢 Open |
| [#3](../../issues/3) | HOOK: Block destructive bash commands in Claude Code | $100 | 🟢 Open |
| [#4](../../issues/4) | AGENT: PR reviewer with structured Markdown output | $150 | 🟢 Open |
| [#5](../../issues/5) | WORKFLOW: n8n + Claude API — automated weekly dev summary | $200 | 🟢 Open |

---

## Rules

- Tasks must be related to Claude Code or AI tooling
- Every issue must have clear acceptance criteria before a bounty is activated
- Payment is handled by [Opire](https://opire.dev) (Stripe)
- Quality over speed — a solid PR beats a fast one

---

## Community

- 🐦 X: [@ClaudeBounty](https://x.com/ClaudeBounty)
- 📧 Contact: claudebounty@gmail.com

---

#!/usr/bin/env python3
"""
Claude Code PR Reviewer Agent

A CLI tool that analyzes GitHub PRs and generates structured Markdown review comments.
"""

import argparse
import os
import sys
import requests
import json
import re
from urllib.parse import urlparse
from github import Github

def parse_pr_url(url):
    """Extract owner, repo, and pull number from a GitHub PR URL"""
    # Pattern: https://github.com/owner/repo/pull/123
    pattern = r"https://github.com/([^/]+)/([^/]+)/pull/(\d+)"
    match = re.match(pattern, url)
    if not match:
        raise ValueError("Invalid GitHub PR URL format")
    owner, repo, pr_number = match.groups()
    return owner, repo, int(pr_number)

def get_pr_diff(owner, repo, pr_number, github_token):
    """Fetch the diff of a PR using GitHub API"""
    g = Github(github_token)
    repo_obj = g.get_repo(f"{owner}/{repo}")
    pr = repo_obj.get_pull(int(pr_number))
    return pr.get_commits().reversed[0].get_patch()

def analyze_code_changes(diff_text):
    """Analyze the code changes and return structured feedback"""
    # This is a simplified analysis - in a real implementation, 
    # this would use Claude Code or other AI analysis
    
    # Simple heuristics for demonstration
    changes_summary = "Code changes have been analyzed."
    risks = []
    suggestions = []
    
    # Basic parsing to identify file changes
    files_changed = set()
    lines_added = 0
    lines_removed = 0
    
    # Simple parsing of unified diff format
    for line in diff_text.split('\n'):
        if line.startswith('diff --git'):
            # Extract file name
            parts = line.split(' ')
            if len(parts) > 3:
                file_path = parts[3].replace('a/', '').replace('b/', '')
                files_changed.add(file_path)
        elif line.startswith('+') and not line.startswith('+++'):
            lines_added += 1
        elif line.startswith('-') and not line.startswith('---'):
            lines_removed += 1
    
    changes_summary = f"This PR modifies {len(files_changed)} file(s) with {lines_added} additions and {lines_removed} deletions."
    
    # Simple risk heuristics
    if lines_added > 100 or lines_removed > 100:
        risks.append("Large changes detected which may increase the risk of bugs.")
    
    if ".env" in diff_text or "password" in diff_text or "secret" in diff_text:
        risks.append("Potential security risk: sensitive information detected in changes.")
        
    if "TODO" in diff_text or "FIXME" in diff_text:
        suggestions.append("Consider removing development notes before merging.")
    
    # Simple confidence calculation
    confidence = "Medium"  # Default
    if lines_added + lines_removed < 50:
        confidence = "High"
    if lines_added + lines_removed > 200:
        confidence = "Low"
        
    return {
        "summary": changes_summary,
        "risks": risks,
        "suggestions": suggestions,
        "confidence": confidence
    }

def format_output(analysis):
    """Format the analysis output as structured Markdown"""
    output = []
    output.append("## Summary of Changes")
    output.append(analysis['summary'])
    output.append("")
    output.append("## Identified Risks")
    if analysis['risks']:
        for risk in analysis['risks']:
            output.append(f"- {risk}")
    else:
        output.append("- No significant risks identified")
    output.append("")
    output.append("## Improvement Suggestions")
    if analysis['suggestions']:
        for suggestion in analysis['suggestions']:
            output.append(f"- {suggestion}")
    else:
        output.append("- No specific suggestions at this time")
    output.append("")
    output.append(f"## Confidence: {analysis['confidence']}")
    return "\n".join(output)

def main():
    parser = argparse.ArgumentParser(description="Claude Code PR Reviewer")
    parser.add_argument("--pr", required=True, help="GitHub PR URL")
    parser.add_argument("--token", help="GitHub token for authentication")
    
    args = parser.parse_args()
    
    try:
        owner, repo, pr_number = parse_pr_url(args.pr)
        diff = get_pr_diff(owner, repo, pr_number, args.token)
        analysis = analyze_code_changes(diff)
        print(format_output(analysis))
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
*Started by the Claude builder community · March 2026 · MIT License*
