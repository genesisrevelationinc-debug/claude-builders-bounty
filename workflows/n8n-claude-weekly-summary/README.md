# n8n + Claude Weekly Dev Summary Workflow

Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`

2. **Set credentials**: Add your GitHub Personal Access Token, Claude API Key, and Email/SMTP or Webhook credentials in n8n *Settings* → *Credentials*

3. **Configure variables**: Open the *Set Config* node and edit:
   - `repo`: `owner/repo` format
   - `channel`: email address or webhook URL
   - `language`: `EN` or `FR`

4. **Activate the workflow**: Toggle the workflow to *Active* — it runs every Friday at 5 PM UTC

5. **Test manually**: Click *Execute Workflow* to verify, then check your destination for the summary

---

## What It Does

- **Trigger**: Weekly cron (Fridays at 5 PM)
- **Fetches**: Commits, closed issues, and merged PRs from the past 7 days
- **Summarizes**: Claude `claude-sonnet-4-20250514` generates a narrative summary
- **Delivers**: Via email (SMTP) or Discord/Slack webhook

## Required Credentials

| Service | Type | How to Get |
|---------|------|-----------|
| GitHub | Personal Access Token | [Settings → Developer settings → PAT](https://github.com/settings/tokens) |
| Claude | API Key | [Anthropic Console](https://console.anthropic.com) |
| Email/SMTP or Webhook | SMTP or HTTP Request | Your email provider or Discord/Slack app |

## Customization

Edit the `Set Config` node to change:
- `repo`: Target GitHub repository
- `channel`: Where summaries are sent
- `language`: `EN` or `FR`
- `deliveryMethod`: `email` or `webhook`