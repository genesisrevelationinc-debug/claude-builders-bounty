# n8n + Claude — Weekly Dev Summary Workflow

Automatically generate and deliver a weekly narrative summary of any GitHub repository's activity using n8n and the Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, go to *Workflows → Import from File* and select `weekly-dev-summary.json`

2. **Set credentials**: Create two credentials in n8n:
   - `claude-api` — Anthropic API key (get from [console.anthropic.com](https://console.anthropic.com))
   - `github-api` — GitHub personal access token (get from [github.com/settings/tokens](https://github.com/settings/tokens))

3. **Configure variables**: Edit the *Set Variables* node and set:
   - `repoOwner` — GitHub organization or user name
   - `repoName` — repository name
   - `language` — `EN` or `FR`
   - `webhookUrl` — your Discord/Slack webhook URL

4. **Activate the workflow**: Toggle the workflow to *Active* in n8n. It runs automatically every Friday at 5 PM.

5. **Test manually**: Click *Execute Workflow* to verify — check the webhook channel for your summary.

---

## What It Does

- **Trigger**: Cron schedule (Fridays at 17:00)
- **Fetches**: Commits, closed issues, and merged PRs from the past 7 days via GitHub API
- **Summarizes**: Sends data to Claude API (`claude-sonnet-4-20250514`) for a narrative summary
- **Delivers**: Posts the summary to a Discord or Slack webhook

## Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `repoOwner` | GitHub owner | `claude-builders-bounty` |
| `repoName` | Repository name | `claude-builders-bounty` |
| `language` | Output language | `EN` or `FR` |
| `webhookUrl` | Discord/Slack webhook | `https://discord.com/api/webhooks/...` |

## Screenshot

![Successful n8n execution](screenshot.png)

---

## License

MIT