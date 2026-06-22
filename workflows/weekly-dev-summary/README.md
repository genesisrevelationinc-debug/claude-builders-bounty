# n8n Weekly Dev Summary Workflow

Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, click *Workflows → Import → From File* and select `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API Key in *Settings → Credentials*
3. **Configure variables**: Edit the *Set Variables* node with your repo, destination, and language
4. **Activate**: Toggle the workflow to *Active* in the top-right corner
5. **Test run**: Click *Execute Workflow* to verify, then check your email/Discord for the summary

## Required Credentials

- **GitHub API**: Personal Access Token with `repo` scope
- **Anthropic API**: API key from [console.anthropic.com](https://console.anthropic.com)

## Configurable Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `githubRepo` | Target repository | `claude-builders-bounty/claude-builders-bounty` |
| `destinationChannel` | Email or webhook URL | `https://hooks.discord.com/...` |
| `language` | Summary language | `EN` or `FR` |

## Delivery Options

- **Email**: Configure SMTP roundup in the *Send Email* node (SMTP credentials required)
- **Discord/Slack**: Set `destinationChannel` to your webhook URL; the workflow auto-detects and routes to the *HTTP Request* node

## Cron Schedule

Default: Every Friday at 5:00 PM UTC (`0 17 * * 5`). Adjust in the *Cron* node as needed.

## Workflow Overview

