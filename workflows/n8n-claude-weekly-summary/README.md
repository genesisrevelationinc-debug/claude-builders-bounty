# n8n + Claude Weekly Dev Summary Workflow

Automated weekly narrative summary of GitHub repo activity using n8n and Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, go to Workflows → Import from File → select `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API Key in n8n Credentials
3. **Configure variables**: Edit the "Set Config" node — set `repoOwner`, `repoName`, `webhookUrl`, and `language` (EN/FR)
4. **Activate**: Toggle the workflow to "Active" — it runs Fridays at 5pm
5. **Test manually**: Click "Execute Workflow" to verify, check your Discord/Slack channel for the summary

## Delivery

This workflow delivers summaries via **Discord webhook** (configurable to Slack). The `webhookUrl` variable accepts any HTTP POST endpoint.

## Required Credentials

- **GitHub API**: Personal Access Token with `repo` scope
- **Anthropic API**: API key from [console.anthropic.com](https://console.anthropic.com)

## Workflow Overview

