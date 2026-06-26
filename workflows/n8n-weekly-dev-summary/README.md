# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of a GitHub repo's activity, powered by n8n + Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub Personal Access Token, Claude API key, and email/SMTP or webhook credentials in n8n *Settings* → *Credentials*
3. **Configure variables**: Open the workflow and edit the `Set Config` node — set `repoOwner`, `repoName`, `destinationType` (`email` or `webhook`), `webhookUrl`, and `language` (`EN` or `FR`)
4. **Activate**: Toggle the workflow to *Active* in the top-right corner
5. **Test**: Click *Execute Workflow* or wait for the next Friday 5 PM — check the output node for your summary

## What It Does

- Triggers every Friday at 5 PM (cron)
- Fetches commits, closed issues, and merged PRs from the past 7 days via GitHub API
- Sends data to Claude API (`claude-sonnet-4-20250514`) to generate a narrative summary
- Delivers the summary via email (SMTP) or webhook (Discord/Slack)

## Configurable Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `repoOwner` | GitHub repository owner | `claude-builders-bounty` |
| `repoName` | GitHub repository name | `claude-builders-bounty` |
| `destinationType` | Delivery method: `email` or `webhook` | `webhook` |
| `webhookUrl` | Discord/Slack webhook URL (if webhook) | `https://discord.com/api/webhooks/...` |
| `emailTo` | Recipient email (if email) | `dev@example.com` |
| `language` | Summary language | `EN` or `FR` |

## Required Credentials

- **GitHub API**: Personal Access Token with `repo` scope
- **Claude API**: Anthropic API key
- **Email (optional)**: SMTP credentials
- **Webhook (optional)**: No credentials needed; URL is set in config

## Nodes Overview

| # | Node | Purpose |
|---|------|---------|
| 1 | Cron | Weekly trigger (Fri 5 PM) |
| 2 | Set Config | Define repo, language, destination |
| 3 | GitHub Commits | Fetch commits from past 7 days |
| 4 | GitHub Issues | Fetch closed issues from past 7 days |
| 5 | GitHub PRs | Fetch merged PRs from past 7 days |
| 6 | Merge Data | Combine all activity data |
| 7 | Claude API | Generate narrative summary |
| 8 | Route Delivery | Switch between email/webhook |
| 9 | Send Email / Webhook | Deliver summary |

## Screenshot

> ![Successful Execution](screenshot-success.png)
>
> *Example of a successful workflow execution in n8n*