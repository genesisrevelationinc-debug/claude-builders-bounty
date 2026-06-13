# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of a GitHub repo's activity, powered by n8n and Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, go to *Workflows* → *Import from File* → select `workflow.json`
2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in *Settings* → *Credentials*
3. **Configure variables**: Open the *Set Config* node and edit:
   - `githubRepo` — e.g. `owner/repo`
   - `destinationWebhook` — your email/Discord/Slack URL
   - `language` — `EN` or `FR`
4. **Activate**: Toggle the workflow to *Active* — it runs Fridays at 5 PM
5. **Test manually**: Click *Execute Workflow* and verify the output in your chosen channel

## What it does

- Triggers weekly via cron (Friday 5 PM)
- Fetches commits, closed issues, and merged PRs from the past 7 days
- Sends structured data to Claude API (`claude-sonnet-4-20250514`)
- Delivers a narrative summary via webhook (Discord/Slack/email)

## Required Credentials

| Service | Credential Type | How to get |
|---------|----------------|------------|
| GitHub | Personal Access Token | https://github.com/settings/tokens |
| Anthropic | API Key | https://console.anthropic.com |

## Nodes Overview

| Node | Purpose |
|------|---------|
| Cron | Weekly trigger (Fridays 17:00) |
| Set Config | Centralized variables |
| GitHub (3×) | Fetch commits, issues, PRs |
| Claude API | Generate narrative summary |
| HTTP Request | Deliver to webhook |

## Screenshot

> Include a screenshot of a successful execution here, e.g.:
> ![n8n execution success](screenshot.png)