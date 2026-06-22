# n8n + Claude Weekly Dev Summary Workflow

Automatically generate and deliver a weekly narrative summary of your GitHub repo's activity using n8n and Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, click **Workflows → Import from File** and select `weekly-dev-summary.json`

2. **Set credentials**: Go to **Settings → Credentials** and add:
   - `claude_api` — your Anthropic API key
   - `github_api` — a GitHub personal access token (classic, with `repo` scope)

3. **Configure variables**: In the workflow, open the **Set Variables** node and set:
   - `repoOwner` — GitHub organization or username
   - `repoName` — repository name
   - `language` — `EN` or `FR`
   - `webhookUrl` — your Discord/Slack webhook URL

4. **Activate the workflow**: Toggle the workflow to **Active** in the top-right corner

5. **Test it**: Click **Execute Workflow** to run manually, or wait for the next Friday at 5 PM UTC

---

## What It Does

- **Trigger**: Runs every Friday at 5:00 PM UTC via cron
- **Fetches**: Commits, closed issues, and merged PRs from the past 7 days
- **Summarizes**: Sends data to Claude API (`claude-sonnet-4-20250514`) for a narrative summary
- **Delivers**: Posts the summary to a Discord or Slack webhook

## Requirements

- n8n v1.0+ (self-hosted or cloud)
- Anthropic API key with access to Claude Sonnet
- GitHub personal access token with `repo` scope
- Discord or Slack incoming webhook URL

## Files

- `weekly-dev-summary.json` — the n8n workflow (import this)
- `README.md` — this file