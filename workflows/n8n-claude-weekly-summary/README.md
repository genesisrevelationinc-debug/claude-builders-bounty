# n8n + Claude Weekly Dev Summary Workflow

Automatically generates a weekly narrative summary of a GitHub repo's activity using n8n and the Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, click **Add Workflow** → **Import from File** → select `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in n8n **Credentials**
3. **Configure variables**: Open the workflow and edit the `Set Config` node — set your repo, destination, and language
4. **Activate the workflow**: Toggle the workflow to **Active** in the top-right corner
5. **Test it**: Click **Execute Workflow** to run manually, or wait for the weekly cron trigger

## Configuration

Edit the `Set Config` node to customize:

| Variable | Description | Example |
|----------|-------------|---------|
| `githubRepo` | Full repo path | `claude-builders-bounty/claude-builders-bounty` |
| `destination` | Email or webhook URL | `https://hooks.slack.com/services/...` |
| `language` | Summary language | `EN` or `FR` |
| `summaryType` | Delivery method | `slack`, `discord`, or `email` |

## Delivery Methods

- **Slack**: Set `summaryType` to `slack` and `destination` to your Slack webhook URL
- **Discord**: Set `summaryType` to `discord` and `destination` to your Discord webhook URL
- **Email**: Set `summaryType` to `email` and `destination` to the recipient email address

## What It Does

1. Triggers every Friday at 5:00 PM
2. Fetches commits, closed issues, and merged PRs from the past 7 days
3. Sends data to Claude API (`claude-sonnet-4-20250514`) for narrative generation
4. Delivers the formatted summary to your chosen destination

## Requirements

- n8n instance (cloud or self-hosted)
- GitHub Personal Access Token
- Anthropic API key
- Slack or Discord webhook (or SMTP for email)