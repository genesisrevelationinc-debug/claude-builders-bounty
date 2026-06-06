# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of GitHub repo activity using n8n + Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, click "Import" → "From File" → select `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub token, Claude API key, and email/SMTP or webhook credentials in n8n "Credentials"
3. **Configure variables**: Open the "Set Variables" node and set your repo, destination, and language (EN/FR)
4. **Activate**: Toggle the workflow to "Active" — it runs Fridays at 5pm
5. **Test**: Click "Execute Workflow" to run manually and verify output

## Required Credentials

- **GitHub API**: Personal access token with `repo` scope
- **Claude API**: Anthropic API key (https://console.anthropic.com)
- **Delivery**: One of:
  - SMTP credentials for email, OR
  - Webhook URL for Discord/Slack

## Configurable Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `githubRepo` | Full repo path | `claude-builders-bounty/claude-builders-bounty` |
| `destinationChannel` | Email or webhook URL | `dev-updates@company.com` |
| `language` | Summary language | `EN` or `FR` |

## Workflow Overview

