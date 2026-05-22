# n8n Weekly Dev Summary Workflow

Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, click *Workflows → Import from File* and select `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API Key in n8n *Settings → Credentials*
3. **Configure variables**: Open the workflow and edit the `Set Config` node — set `repoOwner`, `repoName`, `webhookUrl`, and `language` (EN/FR)
4. **Activate**: Toggle the workflow to *Active* in the top-right corner
5. **Verify**: Click *Execute Workflow* to test, or wait for the weekly cron trigger (Fridays at 5pm UTC)

## Required Credentials

- **GitHub Personal Access Token** (classic or fine-grained with `repo` scope)
- **Anthropic API Key** (from [console.anthropic.com](https://console.anthropic.com))

## Configuration Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `repoOwner` | GitHub organization or user | `claude-builders-bounty` |
| `repoName` | Repository name | `claude-builders-bounty` |
| `webhookUrl` | Discord/Slack webhook URL | `https://discord.com/api/webhooks/...` |
| `language` | Output language | `EN` or `FR` |

## What It Does

1. Triggers every Friday at 5pm UTC
2. Fetches commits, closed issues, and merged PRs from the past 7 days
3. Sends data to Claude API (`claude-sonnet-4-20250514`) for narrative generation
4. Posts the formatted summary to your configured Discord/Slack webhook

## Screenshot

![Successful Execution](screenshot.png)

*Include a screenshot of a successful n8n execution run here.*

## License

MIT