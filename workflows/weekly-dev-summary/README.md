# n8n Weekly Dev Summary Workflow

Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.

## Setup (5 steps)

1. **Import** `workflow.json` into your n8n instance (Settings → Import)
2. **Set credentials** for GitHub, Claude API, and your delivery channel (email/Discord/Slack)
3. **Configure** the `Configuration` node variables: repo, channel, language
4. **Activate** the workflow — it runs Fridays at 5 PM
5. **Test** manually with the "Execute Workflow" button

## Required Credentials

- **GitHub API**: Personal access token with `repo` scope
- **Claude API**: Anthropic API key (https://console.anthropic.com)
- **Delivery**: SMTP for email, or webhook URL for Discord/Slack

## Configuration Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `githubRepo` | Full repo path | `claude-builders-bounty/claude-builders-bounty` |
| `destinationChannel` | Email or webhook URL | `https://discord.com/api/webhooks/...` |
| `language` | Summary language | `EN` or `FR` |

## Workflow Overview

