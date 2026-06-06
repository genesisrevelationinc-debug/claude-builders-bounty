# n8n Weekly Dev Summary Workflow

Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, click **Settings** → **Workflows** → **Import from File** → select `weekly-dev-summary.json`

2. **Set credentials**: Add your **GitHub API**, **Claude API**, and **Discord/Slack Webhook** credentials in n8n

3. **Configure variables**: Open the **"Set Config"** node and set:
   - `repoOwner` — GitHub organization or user name
   - `repoName` — repository name
   - `language` — `EN` or `FR`
   - `webhookUrl` — your Discord/Slack webhook URL (or configure email node instead)

4. **Activate**: Toggle the workflow to **Active** in the top-right corner

5. **Test**: Click **"Execute Workflow"** to run manually, or wait for the weekly cron trigger (Fridays at 5 PM UTC)

---

## What It Does

- **Trigger**: Weekly cron (Fridays at 5:00 PM UTC)
- **GitHub API**: Fetches commits, closed issues, and merged PRs from the past 7 days
- **Claude API**: Generates a narrative summary using `claude-sonnet-4-20250514`
- **Delivery**: Posts summary to Discord/Slack via webhook (or email — configurable)

## Required Credentials

| Service | Credential Type |
|---------|-----------------|
| GitHub | GitHub API (personal access token) |
| Claude | Anthropic API (API key) |
| Discord/Slack | Webhook URL |

## Customization

- Change `language` in the **"Set Config"** node to `FR` for French summaries
- Swap the **"Send to Discord"** node for an **Email** node to use email delivery
- Adjust the cron schedule in the **"Weekly Trigger"** node as needed

---

*Tested on n8n v1.50+*