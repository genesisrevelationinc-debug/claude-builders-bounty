# n8n + Claude Weekly Dev Summary Workflow

Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, go to Workflows → Import from File → select `claude-weekly-summary.json`
2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API Key in n8n Credentials
3. **Configure variables**: Edit the "Set Config" node — set `repoOwner`, `repoName`, `discordWebhookUrl`, and `language` (EN/FR)
4. **Activate**: Toggle the workflow to "Active" — it runs Fridays at 5 PM
5. **Test manually**: Click "Execute Workflow" to verify — check your Discord channel for the summary

## Required Credentials

- **GitHub API**: Personal Access Token with `repo` scope
- **Anthropic API**: API key from [console.anthropic.com](https://console.anthropic.com)

## Configurable Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `repoOwner` | GitHub repository owner | `claude-builders-bounty` |
| `repoName` | GitHub repository name | `claude-builders-bounty` |
| `discordWebhookUrl` | Discord webhook URL for delivery | `https://discord.com/api/webhooks/...` |
| `language` | Summary language | `EN` or `FR` |

## What It Does

1. Triggers weekly (Friday 5 PM via cron)
2. Fetches commits, closed issues, and merged PRs from the past 7 days
3. Sends data to Claude API (`claude-sonnet-4-20250514`) for narrative generation
4. Posts the formatted summary to Discord via webhook

## Output Example

