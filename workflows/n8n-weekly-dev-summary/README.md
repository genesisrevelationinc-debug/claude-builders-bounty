# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of GitHub repo activity using n8n + Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, click *Workflows → Import from File* and select `weekly-dev-summary.json`

2. **Set credentials**: Add your **Claude API** key (Anthropic) and **GitHub Personal Access Token** in n8n *Settings → Credentials*

3. **Configure variables**: Open the workflow and edit the `Set Config` node:
   - `repoOwner` / `repoName` — target GitHub repository
   - `webhookUrl` — Discord/Slack incoming webhook URL
   - `language` — `EN` or `FR`

4. **Activate**: Toggle the workflow *Active* — it runs automatically every Friday at 5 PM

5. **Verify**: Click *Execute Workflow* manually and check the webhook channel for the summary

---

## What It Does

- **Trigger**: Weekly cron (Fridays at 17:00)
- **Fetches**: Commits, closed issues, and merged PRs from the past 7 days via GitHub API
- **Summarizes**: Sends data to Claude API (`claude-sonnet-4-20250514`) for a narrative summary
- **Delivers**: Posts the summary to a Discord/Slack webhook

## Required Credentials

| Service | Credential Type | How to Get |
|---------|---------------|------------|
| Claude API | Anthropic API Key | https://console.anthropic.com |
| GitHub API | Personal Access Token | https://github.com/settings/tokens |

## Nodes Overview

1. **Cron Trigger** — weekly schedule
2. **Set Config** — defines repo, webhook, language
3. **GitHub Commits/Issues/PRs** — fetches weekly activity
4. **Merge Data** — combines results
5. **Claude API** — generates narrative summary
6. **Discord/Slack Webhook** — delivers the summary
7. **Error Handler** — catches and logs failures