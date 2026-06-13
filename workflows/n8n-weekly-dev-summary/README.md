# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of a GitHub repo's activity, powered by n8n and Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, go to *Workflows → Import from File* and select `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in *Settings → Credentials*
3. **Configure variables**: Open the workflow and edit the `Set Config` node — set `repoOwner`, `repoName`, `discordWebhookUrl`, and `language` (`EN` or `FR`)
4. **Activate the workflow**: Toggle the workflow to *Active* — it runs automatically every Friday at 5 PM
5. **Test manually**: Click *Execute Workflow* to verify it works, then check your Discord channel

## What It Does

- **Trigger**: Weekly cron (Fridays at 17:00)
- **Fetches**: Commits, closed issues, and merged PRs from the past 7 days via GitHub API
- **Summarizes**: Sends data to Claude API (`claude-sonnet-4-20250514`) for a narrative summary
- **Delivers**: Posts the summary to a Discord webhook (configurable)

## Required Credentials

| Service | Credential Type | How to Get |
|---------|----------------|------------|
| GitHub | Personal Access Token | [GitHub Settings → Developer Settings → Tokens](https://github.com/settings/tokens) |
| Anthropic | API Key | [Anthropic Console](https://console.anthropic.com/) |

## Configurable Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `repoOwner` | GitHub repository owner | `claude-builders-bounty` |
| `repoName` | GitHub repository name | `claude-builders-bounty` |
| `discordWebhookUrl` | Discord webhook URL for delivery | `https://discord.com/api/webhooks/...` |
| `language` | Summary language (`EN` or `FR`) | `EN` |

## Nodes Overview

| Node | Purpose |
|------|---------|
| Cron Trigger | Runs weekly on Fridays at 17:00 |
| Set Config | Defines repo, webhook, and language variables |
| GitHub (3x) | Fetch commits, closed issues, merged PRs |
| Claude API | Generate narrative summary |
| Discord Webhook | Deliver the summary |

## Screenshot

![Successful Execution](screenshot.png)

*Screenshot of successful execution on a real n8n instance.*