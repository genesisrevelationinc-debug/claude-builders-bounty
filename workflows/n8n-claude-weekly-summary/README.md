# n8n + Claude Weekly Dev Summary Workflow

Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, click "Import" → "From File" → select `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API Key in n8n credentials
3. **Configure variables**: Update the `Set Config` node with your repo, destination, and language
4. **Activate workflow**: Toggle the workflow to "Active" in n8n
5. **Test run**: Click "Execute Workflow" to verify, then wait for Friday 5pm ⏰

## Required Credentials

- **GitHub Personal Access Token** (no special scopes needed for public repos; `repo` scope for private)
- **Anthropic API Key** from [console.anthropic.com](https://console.anthropic.com)

## Configurable Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `githubRepo` | Full repo path | `claude-builders-bounty/claude-builders-bounty` |
| `destination` | Webhook URL for delivery | `https://hooks.slack.com/services/...` |
| `language` | Summary language | `EN` or `FR` |

## Delivery Options

The workflow uses a **webhook** node for delivery. Configure one of:
- **Slack**: Incoming Webhook URL
- **Discord**: Webhook URL (ends with `/slack` if using Slack-compatible)
- **Email**: Replace webhook with n8n's Email node (SMTP required)

## What It Does

1. ⏰ Triggers every Friday at 5:00 PM
2. 📊 Fetches commits, closed issues, and merged PRs from the past 7 days
3. 🤖 Sends data to Claude API (`claude-sonnet-4-20250514`) for narrative generation
4. 📬 Delivers the formatted summary to your configured channel

## Files

- `weekly-dev-summary.json` — Importable n8n workflow
- `README.md` — This file

## Screenshot

> 📸 *Include a screenshot of a successful execution here*
> 
> Example: `assets/n8n-execution-success.png`