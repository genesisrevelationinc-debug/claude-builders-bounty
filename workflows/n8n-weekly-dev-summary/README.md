# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of GitHub repo activity using n8n + Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`

2. **Set credentials**: Add your **Claude API** and **GitHub** credentials in n8n *Settings* → *Credentials*

3. **Configure variables**: Open the workflow and edit the `Set Config` node:
   - `repo`: GitHub owner/repo (e.g., `claude-builders-bounty/claude-builders-bounty`)
   - `channel`: Email address or webhook URL for delivery
   - `language`: `EN` or `FR`

4. **Set delivery method**: In the `Switch Delivery` node, choose `email` or `webhook` branch and configure the corresponding node

5. **Activate**: Toggle the workflow to *Active* — it runs every Friday at 5 PM

## What It Does

- **Trigger**: Weekly cron (Fridays at 17:00)
- **Fetches**: Commits, closed issues, and merged PRs from the past 7 days via GitHub API
- **Summarizes**: Sends data to Claude API (`claude-sonnet-4-20250514`) for a narrative summary
- **Delivers**: Posts summary via email (SMTP) or webhook (Discord/Slack)

## Required Environment Variables / Credentials

| Credential | Where to Get |
|------------|-------------|
| Claude API Key | [Anthropic Console](https://console.anthropic.com) |
| GitHub Personal Access Token | [GitHub Settings](https://github.com/settings/tokens) |
| SMTP credentials (optional) | Your email provider |

## Testing

Run the workflow manually in n8n and check the execution output. A successful run shows green checkmarks on all nodes.

---

*Created for [Claude Builders Bounty #5](https://github.com/claude-builders-bounty/claude-builders-bounty/issues/5)*