# n8n + Claude — Automated Weekly Dev Summary

Weekly workflow that fetches GitHub activity and generates a narrative summary via Claude API.

## Setup (5 steps)

1. **Import** `workflow.json` into n8n (Settings → Import/Export → Import)
2. **Set credentials**: Add your GitHub token, Claude API key, and email/SMTP or webhook URL in n8n Credentials
3. **Configure variables**: Edit the "Set Config" node — set `repo`, `channel`, and `language` (EN/FR)
4. **Activate** the workflow toggle in the top-right corner
5. **Test**: Click "Execute Workflow" or wait for the Friday 5pm cron trigger

## Required Credentials

| Service | Credential Type | How to Obtain |
|---------|----------------|---------------|
| GitHub | Personal Access Token | [Settings → Developer settings → PAT](https://github.com/settings/tokens) |
| Claude | API Key | [Console → API Keys](https://console.anthropic.com/) |
| Email | SMTP or SendGrid | Your email provider or [SendGrid](https://sendgrid.com) |

## Configurable Variables

Edit the **"Set Config"** node to customize:

| Variable | Description | Example |
|----------|-------------|---------|
| `repo` | GitHub repository (owner/repo) | `claude-builders-bounty/claude-builders-bounty` |
| `channel` | Email address or webhook URL | `dev-team@company.com` or `https://hooks.slack.com/...` |
| `language` | Summary language | `EN` or `FR` |

## What It Does

1. **Triggers** every Friday at 5:00 PM
2. **Fetches** commits, closed issues, and merged PRs from the past 7 days
3. **Sends** to Claude API (`claude-sonnet-4-20250514`) for narrative generation
4. **Delivers** the summary via email (or Discord/Slack webhook if configured)

## Testing

Run the workflow manually and check the execution output. A successful run shows green checkmarks on all nodes.

> 💡 **Tip**: Use a test repo with recent activity to verify the full pipeline.