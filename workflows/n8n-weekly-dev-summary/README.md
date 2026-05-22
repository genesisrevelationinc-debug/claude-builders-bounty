# n8n Weekly Dev Summary Workflow

Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, click *Workflows → Import from File* and select `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API Key in n8n *Settings → Credentials*
3. **Configure variables**: Open the workflow and edit the `Set Config` node — set `repoOwner`, `repoName`, `webhookUrl`, and `language` (EN/FR)
4. **Activate**: Toggle the workflow to *Active* in the top-right corner
5. **Done!** The workflow runs every Friday at 5 PM. Check the first execution in the *Executions* tab

## What It Does

- Triggers weekly (cron: `0 17 * * 5`)
- Fetches commits, closed issues, and merged PRs from the past 7 days via GitHub API
- Sends data to Claude API (`claude-sonnet-4-20250514`) for narrative summarization
- Delivers the summary via Discord/Slack webhook

## Required Credentials

- `githubApi`: GitHub Personal Access Token (no special scopes needed for public repos; `repo` scope for private)
- `anthropicApi`: Anthropic API Key from [console.anthropic.com](https://console.anthropic.com)

## Configurable Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `repoOwner` | GitHub organization or user | `claude-builders-bounty` |
| `repoName` | Repository name | `claude-builders-bounty` |
| `webhookUrl` | Discord/Slack incoming webhook URL | `https://discord.com/api/webhooks/...` |
| `language` | Output language | `EN` or `FR` |

## Screenshot

> 📸 *See `screenshot-success.png` in this directory for a successful execution example.*

## Notes

- The workflow uses n8n's built-in HTTP Request nodes for GitHub API calls
- Claude prompt is optimized for concise, developer-friendly summaries
- Webhook delivery falls back to console log if webhook URL is empty (for testing)
