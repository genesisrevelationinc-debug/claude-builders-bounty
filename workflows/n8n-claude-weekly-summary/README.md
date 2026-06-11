# n8n + Claude Weekly Dev Summary Workflow

Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, go to Workflows → Import from File → select `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub API token, Claude API key, and email/SMTP or webhook credentials in n8n Settings → Credentials
3. **Configure variables**: Edit the "Set Config" node with your repo, destination, and language (EN/FR)
4. **Activate**: Toggle the workflow to "Active" — it runs Fridays at 5 PM
5. **Test**: Click "Execute Workflow" to run manually and verify output

## Required Credentials

- **GitHub API**: Personal access token with `repo` scope
- **Claude API**: Anthropic API key (https://console.anthropic.com)
- **Delivery**: One of:
  - SMTP credentials for email
  - Discord webhook URL
  - Slack webhook URL

## Configurable Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `githubRepo` | Full repo path | `claude-builders-bounty/claude-builders-bounty` |
| `destination` | Email or webhook URL | `https://discord.com/api/webhooks/...` |
| `language` | Summary language | `EN` or `FR` |

## Workflow Overview

