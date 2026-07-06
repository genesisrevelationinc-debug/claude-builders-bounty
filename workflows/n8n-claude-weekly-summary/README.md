# n8n + Claude — Weekly Dev Summary Workflow

Automatically generate and deliver a narrative weekly summary of any GitHub repo's activity using n8n and Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, go to *Workflows → Import from File* and select `weekly-dev-summary.json`.
2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in *Settings → Credentials*.
3. **Configure variables**: Open the `Set Config` node and edit:
   - `repoOwner` / `repoName` — target repository
   - `webhookUrl` — your Discord/Slack webhook
   - `language` — `EN` or `FR`
4. **Activate the workflow**: Toggle the workflow to *Active* — it runs every Friday at 5 PM UTC.
5. **Test manually**: Click *Execute Workflow* to verify; check the webhook channel for the summary.

## What It Does

- **Trigger**: Weekly cron (Fridays at 17:00 UTC)
- **Fetches**: Commits, closed issues, and merged PRs from the past 7 days via GitHub API
- **Summarizes**: Sends data to Claude API (`claude-sonnet-4-20250514`) for a narrative summary
- **Delivers**: Posts the summary to a Discord or Slack webhook

## Required Credentials

| Service | Type | How to Get |
|---------|------|-----------|
| GitHub | Personal Access Token | [Settings → Developer settings → Personal access tokens](https://github.com/settings/tokens) |
| Anthropic | API Key | [Console → API keys](https://console.anthropic.com/settings/keys) |

## Configurable Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `repoOwner` | GitHub repository owner | `claude-builders-bounty` |
| `repoName` | GitHub repository name | `claude-builders-bounty` |
| `webhookUrl` | Discord/Slack incoming webhook | `https://discord.com/api/webhooks/...` |
| `language` | Output language | `EN` or `FR` |

## Screenshot

![Successful n8n execution](screenshot.png)

*Screenshot shows a successful execution with the webhook delivery node returning status 204.*

## License

MIT — same as the parent repo.