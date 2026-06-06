# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of a GitHub repo's activity, powered by n8n and Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, go to *Workflows → Import from File* and select `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in *Settings → Credentials*
3. **Configure variables**: Open the workflow and edit the `Configuration` node — set your repo, destination, and language
4. **Activate the workflow**: Toggle the workflow to *Active* — it runs automatically every Friday at 5 PM
5. **Test manually**: Click *Execute Workflow* to verify and check your email/Discord for the summary

## Configuration Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `githubRepo` | Full GitHub repo path | `claude-builders-bounty/claude-builders-bounty` |
| `destinationChannel` | Email address or Discord webhook URL | `dev-updates@company.com` or `https://discord.com/api/webhooks/...` |
| `language` | Summary language | `EN` or `FR` |

## Delivery Options

- **Email**: Set `destinationChannel` to an email address (requires n8n SMTP credentials)
- **Discord**: Set `destinationChannel` to a Discord webhook URL

## Required Credentials

- **GitHub API**: Personal Access Token with `repo` scope
- **Anthropic API**: API key from [console.anthropic.com](https://console.anthropic.com)
- **SMTP** (if using email): Configure in n8n *Settings → Credentials*

## Workflow Overview

