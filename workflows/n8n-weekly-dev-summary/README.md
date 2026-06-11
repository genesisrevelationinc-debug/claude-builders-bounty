# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of a GitHub repo's activity, powered by n8n + Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, click **Add Workflow** → **Import from File** → select `workflow.json`

2. **Set credentials**: Add your **Claude API** key and **GitHub Personal Access Token** in n8n's **Credentials** section

3. **Configure variables**: Open the **Set Config** node and edit:
   - `githubRepo` — target repository (e.g., `owner/repo`)
   - `webhookUrl` — your Discord/Slack webhook URL
   - `language` — `EN` or `FR`

4. **Activate the workflow**: Toggle the workflow to **Active** — it runs automatically every Friday at 5 PM

5. **Test manually**: Click **Execute Workflow** to run a test and verify output in your Discord/Slack channel

## What It Does

- **Trigger**: Weekly cron (Fridays at 17:00)
- **Fetches**: Commits, closed issues, and merged PRs from the past 7 days via GitHub API
- **Generates**: Narrative summary via Claude API (`claude-sonnet-4-20250514`)
- **Delivers**: Summary to Discord/Slack webhook

## Required Credentials

| Service | Credential Type | How to Get |
|---------|---------------|------------|
| Claude API | API Key | [Anthropic Console](https://console.anthropic.com) |
| GitHub | Personal Access Token | [GitHub Settings](https://github.com/settings/tokens) |

## Nodes Overview

| Node | Purpose |
|------|---------|
| Cron | Weekly trigger (Friday 5 PM) |
| Set Config | Workflow variables (repo, webhook, language) |
| GitHub (3x) | Fetch commits, closed issues, merged PRs |
| Claude API | Generate narrative summary |
| Discord/Slack | Deliver the summary |

## Screenshot

> Include a screenshot of a successful execution here after testing.