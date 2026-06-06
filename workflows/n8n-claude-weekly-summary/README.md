# n8n + Claude Weekly Dev Summary Workflow

Automatically generate and deliver a weekly narrative summary of your GitHub repo's activity using n8n and Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, go to *Workflows → Import from File* and select `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub API token and Claude API key in *Settings → Credentials*
3. **Configure variables**: Open the `Configuration` node and set your repo, destination, and language
4. **Activate**: Toggle the workflow to *Active* in the top-right corner
5. **Test run**: Click *Execute Workflow* to verify — check your email/Discord for the summary

## Required Credentials

- `githubApi` — GitHub personal access token (classic or fine-grained)
- `claudeApi` — Anthropic API key (starts with `sk-ant-`)

## Configurable Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `githubRepo` | Target repository (`owner/repo`) | `claude-builders-bounty/claude-builders-bounty` |
| `destination` | Email address or webhook URL | — |
| `language` | Summary language (`EN` or `FR`) | `EN` |
| `weeksAgo` | How many weeks back to summarize | `1` |

## Delivery Options

- **Email**: Set `destination` to your email address (uses n8n built-in email node)
- **Discord**: Set `destination` to a Discord webhook URL
- **Slack**: Set `destination` to a Slack incoming webhook URL

## Workflow Overview

