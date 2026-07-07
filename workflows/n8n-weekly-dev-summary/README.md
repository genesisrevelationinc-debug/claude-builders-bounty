# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of GitHub repo activity using n8n + Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, click "Add Workflow" → "Import from File" → select `weekly-dev-summary.json`

2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in n8n Credentials

3. **Configure variables**: Edit the "Set Config" node with your repo, destination webhook/URL, and language (EN/FR)

4. **Activate**: Toggle the workflow to "Active" — it runs Fridays at 5 PM

5. **Test**: Click "Execute Workflow" to run manually and verify output

## Required Credentials

- **GitHub API**: Personal Access Token with `repo` scope
- **Anthropic**: API key from [console.anthropic.com](https://console.anthropic.com)

## Configurable Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `githubRepo` | Target repository (owner/repo) | `claude-builders-bounty/claude-builders-bounty` |
| `destination` | Email OR webhook URL for delivery | Discord webhook |
| `language` | Summary language: `EN` or `FR` | `EN` |

## Delivery Options

The workflow supports email (SMTP) or webhook (Discord/Slack). Configure in the "Set Config" node:

- **Email**: Set `deliveryType` to `email` and provide SMTP credentials
- **Webhook**: Set `deliveryType` to `webhook` and provide webhook URL

## Workflow Overview

1. **Cron Trigger**: Every Friday at 5:00 PM
2. **GitHub Commits**: Fetch commits from the past 7 days
3. **GitHub Closed Issues**: Fetch issues closed in the past 7 days
4. **GitHub Merged PRs**: Fetch PRs merged in the past 7 days
5. **Claude API**: Generate narrative summary in configured language
6. **Deliver**: Send via email or webhook

## Screenshot

![Successful Execution](screenshot-success.png)
