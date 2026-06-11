# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of a GitHub repo's activity, powered by n8n and Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`

2. **Set credentials**: Open the *GitHub* node and enter your [GitHub Personal Access Token](https://github.com/settings/tokens) (needs `repo` scope). Open the *Claude API* node and enter your [Anthropic API key](https://console.anthropic.com).

3. **Configure variables**: Edit the *Set Variables* node and set:
   - `repoOwner` — GitHub organization or user name
   - `repoName` — repository name
   - `language` — `EN` or `FR`
   - `webhookUrl` — your Discord/Slack webhook URL

4. **Activate the workflow**: Toggle the workflow to *Active* in the top-right corner.

5. **Test it**: Click *Execute Workflow* or wait for the Friday 5 PM cron trigger. Check your Discord/Slack channel for the summary.

---

## What It Does

- **Trigger**: Every Friday at 5:00 PM (cron: `0 17 * * 5`)
- **Fetches** from GitHub API (last 7 days):
  - Commits
  - Closed issues
  - Merged pull requests
- **Generates** a narrative summary via Claude API (`claude-sonnet-4-20250514`)
- **Delivers** the summary to a Discord or Slack webhook

## Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `repoOwner` | GitHub owner | `claude-builders-bounty` |
| `repoName` | GitHub repo | `claude-builders-bounty` |
| `language` | Output language | `EN` or `FR` |
| `webhookUrl` | Discord/Slack webhook | `https://discord.com/api/webhooks/...` |

## Screenshot

![Successful n8n execution](screenshot.png)

*Example of a successful workflow execution in n8n.*

## Nodes Overview

| Node | Purpose |
|------|---------|
| Cron | Weekly trigger (Friday 5 PM) |
| Set Variables | Configurable parameters |
| GitHub (3×) | Fetch commits, closed issues, merged PRs |
| Claude API | Generate narrative summary |
| Discord/Slack Webhook | Deliver the summary |

---