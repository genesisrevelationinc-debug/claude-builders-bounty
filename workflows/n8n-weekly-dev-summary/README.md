# n8n Weekly Dev Summary Workflow

Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, click **Add Workflow** → **Import from File** → select `weekly-dev-summary.json`

2. **Set credentials**: Add your GitHub Personal Access Token, Claude API key, and email/SMTP or webhook credentials in n8n **Settings → Credentials**

3. **Configure variables**: Open the **Set Config** node and set:
   - `githubRepo` (e.g., `owner/repo-name`)
   - `destination` (email address or webhook URL)
   - `language` (`EN` or `FR`)

4. **Activate**: Toggle the workflow to **Active** — it runs every Friday at 5 PM

5. **Test manually**: Click **Execute Workflow** to verify, then check your email/Discord/Slack for the summary

## Requirements

- n8n instance (cloud or self-hosted)
- GitHub Personal Access Token (classic, with `repo` scope)
- Claude API key from [Anthropic Console](https://console.anthropic.com)
- Email (SMTP) or Discord/Slack webhook URL for delivery

## Workflow Overview

| Node | Purpose |
|------|---------|
| Cron Trigger | Runs weekly (Friday 5 PM) |
| Set Config | Configurable variables |
| GitHub Commits | Fetch commits from the past 7 days |
| GitHub Issues | Fetch closed issues from the past 7 days |
| GitHub PRs | Fetch merged PRs from the past 7 days |
| Merge Data | Combine all GitHub data |
| Claude API | Generate narrative summary |
| Send Summary | Deliver via email or webhook |

## Screenshot

> Include a screenshot of successful execution here: `screenshot-success.png`