# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of GitHub repo activity using n8n + Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, click *Workflows* → *Import from File* → select `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub Personal Access Token, Claude API key, and webhook/email credentials in n8n *Settings* → *Credentials*
3. **Configure variables**: Open the *Set Variables* node and set `repoOwner`, `repoName`, `destinationWebhook`, and `language` (EN or FR)
4. **Activate workflow**: Toggle the workflow to *Active* — it runs every Friday at 5 PM
5. **Test run**: Click *Execute Workflow* to verify, then check your destination channel for the summary

## Required Credentials

- **GitHub Personal Access Token** (classic or fine-grained with `repo` scope)
- **Anthropic API Key** (from [console.anthropic.com](https://console.anthropic.com))
- **Discord Webhook URL** or **SMTP credentials** for email delivery

## Configurable Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `repoOwner` | GitHub repository owner | `claude-builders-bounty` |
| `repoName` | GitHub repository name | `claude-builders-bounty` |
| `destinationWebhook` | Discord/Slack webhook URL | `https://discord.com/api/webhooks/...` |
| `language` | Summary language | `EN` or `FR` |

## Workflow Overview

