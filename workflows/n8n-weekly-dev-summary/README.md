# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of GitHub repo activity using n8n + Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, go to *Workflows → Import from File* and select `weekly-dev-summary.json`

2. **Set credentials**: Add your *GitHub* and *Anthropic (Claude)* API credentials in n8n *Settings → Credentials*

3. **Configure variables**: Open the workflow and edit the **Set Config** node:
   - `repoOwner` / `repoName` — target GitHub repository
   - `webhookUrl` — Discord/Slack incoming webhook URL
   - `language` — `EN` or `FR`

4. **Activate**: Toggle the workflow *Active* — it runs automatically every Friday at 5 PM

5. **Test manually**: Click *Execute Workflow* to verify, then check your Discord/Slack channel

---

## What It Does

- **Trigger**: Cron schedule (weekly, Friday 17:00)
- **Fetches**: Commits, closed issues, and merged PRs from the past 7 days via GitHub API
- **Summarizes**: Sends data to Claude API (`claude-sonnet-4-20250514`) for a narrative summary
- **Delivers**: Posts the formatted summary to a Discord or Slack webhook

## Required Credentials

| Service | Credential Type | How to Obtain |
|---------|---------------|---------------|
| GitHub | OAuth2 or Personal Access Token | [GitHub Settings → Developer settings → Personal access tokens](https://github.com/settings/tokens) |
| Anthropic Claude | API Key | [Anthropic Console](https://console.anthropic.com/) |

## Nodes Overview

| Node | Purpose |
|------|---------|
| Cron | Weekly trigger (Friday 17:00) |
| Set Config | Workflow variables (repo, webhook, language) |
| GitHub (3×) | Fetch commits, closed issues, merged PRs |
| Claude API | Generate narrative summary |
| Discord/Slack Webhook | Deliver summary |

> **Tip**: The `language` variable switches the Claude prompt between English and French automatically.