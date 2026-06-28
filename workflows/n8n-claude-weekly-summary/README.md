# n8n + Claude Weekly Dev Summary Workflow

Automated weekly narrative summary of GitHub repo activity, powered by n8n and Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, click *Workflows → Import from File* and select `claude-weekly-summary.json`

2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API Key in *Settings → Credentials*

3. **Configure variables**: Open the workflow and edit the `Configuration` node:
   - `repo`: GitHub repo (format: `owner/repo`)
   - `channel`: Email address or webhook URL
   - `language`: `EN` or `FR`
   - `deliveryMethod`: `email` or `webhook`

4. **Activate**: Toggle the workflow to *Active* — it runs every Friday at 5 PM

5. **Test**: Click *Execute Workflow* to run manually and verify output

---

## Delivery Methods

| Method | Configuration |
|--------|---------------|
| Email | Set `deliveryMethod` to `email`, `channel` to your email address. Requires SMTP credentials in n8n. |
| Webhook | Set `deliveryMethod` to `webhook`, `channel` to Discord/Slack webhook URL. No extra credentials needed. |

## Required Scopes

- **GitHub Token**: `repo` (private repos) or `public_repo` (public repos)
- **Anthropic Key**: Standard API access to `claude-sonnet-4-20250514`

## Workflow Overview

1. **Cron Trigger** — Every Friday at 17:00 UTC
2. **GitHub Commits** — Fetch commits from the past 7 days
3. **GitHub Issues** — Fetch closed issues from the past 7 days
4. **GitHub PRs** — Fetch merged PRs from the past 7 days
5. **Claude Summarize** — Generate narrative summary via `claude-sonnet-4-20250514`
6. **Deliver** — Send via email or webhook based on configuration