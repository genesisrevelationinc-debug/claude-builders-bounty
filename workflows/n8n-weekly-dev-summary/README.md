# n8n Weekly Dev Summary Workflow

Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, go to *Workflows → Import from File* and select `weekly-dev-summary.json`

2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API Key in *Settings → Credentials*

3. **Configure variables**: Open the workflow and edit the `Set Config` node — set `repoOwner`, `repoName`, `language` (EN/FR), and `webhookUrl`

4. **Activate the cron trigger**: The workflow runs every Friday at 5 PM UTC by default — adjust in the `Weekly Cron` node if needed

5. **Activate the workflow**: Toggle the workflow to *Active* — it will run automatically and post summaries to your configured Discord/Slack webhook

## What It Does

- Fetches commits, closed issues, and merged PRs from the past 7 days
- Sends structured data to Claude API (`claude-sonnet-4-20250514`)
- Generates a narrative weekly summary
- Delivers the summary via Discord/Slack webhook

## Required Credentials

- **GitHub Personal Access Token** (classic or fine-grained with `repo` scope)
- **Anthropic API Key** (from [console.anthropic.com](https://console.anthropic.com))

## Configurable Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `repoOwner` | GitHub repository owner | `claude-builders-bounty` |
| `repoName` | GitHub repository name | `claude-builders-bounty` |
| `language` | Summary language (`EN` or `FR`) | `EN` |
| `webhookUrl` | Discord/Slack webhook URL | (required) |

## Screenshot

![Successful n8n execution](screenshot.png)

*Include a screenshot of your successful execution here after testing.*