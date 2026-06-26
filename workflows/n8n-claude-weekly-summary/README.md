# n8n + Claude Weekly Dev Summary Workflow

Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.

## Setup (5 steps)

1. **Import** `weekly-dev-summary.json` into your n8n instance (Settings → Import)
2. **Configure credentials**: Add GitHub API token, Claude API key, and email/SMTP or webhook credentials
3. **Set workflow variables** in the "Set Config" node: `repoOwner`, `repoName`, `destination` (email/webhook URL), `language` (EN/FR)
4. **Activate** the workflow toggle — it runs automatically every Friday at 5pm
5. **Test manually** by clicking "Execute Workflow" and verify delivery

## Required Credentials

- **GitHub API**: Personal access token with `repo` scope
- **Claude API**: Anthropic API key (https://console.anthropic.com)
- **Delivery**: SMTP credentials for email, or webhook URL for Discord/Slack

## Configurable Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `repoOwner` | GitHub repository owner | `claude-builders-bounty` |
| `repoName` | GitHub repository name | `claude-builders-bounty` |
| `destination` | Email address or webhook URL | `team@example.com` or `https://hooks.slack.com/...` |
| `language` | Summary language | `EN` or `FR` |

## What It Does

1. Triggers weekly (Friday 5pm cron: `0 17 * * 5`)
2. Fetches commits, closed issues, and merged PRs from the past 7 days
3. Sends data to Claude API (`claude-sonnet-4-20250514`) for narrative generation
4. Delivers the formatted summary via email or webhook

## Testing

Run the workflow manually in n8n and check the execution output. A successful run shows green nodes and delivers the summary to your configured destination.

## Notes

- The workflow uses n8n's built-in HTTP Request nodes for GitHub API calls
- Claude prompt is optimized for technical audience with clear section headers
- Supports both English and French summaries based on `language` variable