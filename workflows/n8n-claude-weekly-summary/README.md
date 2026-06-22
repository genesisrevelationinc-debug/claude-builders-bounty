# n8n + Claude Weekly Dev Summary Workflow

Automated weekly narrative summary of GitHub repo activity using n8n and Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, click "Import" and upload `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub token and Claude API key in n8n credentials
3. **Configure variables**: Edit the "Set Config" node with your repo, channel, and language
4. **Activate**: Toggle the workflow to "Active" in n8n
5. **Test**: Click "Execute Workflow" to verify, or wait for the Friday 5pm cron trigger

## Required Credentials

- **GitHub API**: Personal access token with `repo` scope
- **Claude API**: Anthropic API key from [console.anthropic.com](https://console.anthropic.com)

## Configuration Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `githubRepo` | Full repo path | `owner/repo-name` |
| `destinationWebhook` | Email/Discord/Slack URL | `https://hooks.slack.com/...` |
| `language` | Summary language | `EN` or `FR` |

## Delivery Method

This workflow uses **Discord webhook** by default (configurable to Slack or email). Create a webhook in your Discord server settings → Integrations → Webhooks, and paste the URL in the config.

## Workflow Overview

