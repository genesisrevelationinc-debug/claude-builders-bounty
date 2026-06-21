# n8n Weekly Dev Summary Workflow

Automatically generate a weekly narrative summary of a GitHub repo's activity using Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, go to *Workflows* → *Import from File* → select `workflow.json`
2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API Key in *Settings* → *Credentials*
3. **Configure variables**: Open the *Set Config* node and edit: `repo` (e.g. `owner/repo`), `webhookUrl`, `language` (`EN` or `FR`)
4. **Activate**: Toggle the workflow to *Active* — it runs every Friday at 5 PM
5. **Test manually**: Click *Execute Workflow* to verify; check the *Execution* tab for results

## What It Does

- Fetches commits, closed issues, and merged PRs from the past 7 days via GitHub API
- Sends the data to Claude API (`claude-sonnet-4-20250514`) for a narrative summary
- Delivers the summary via Discord/Slack webhook

## Required Credentials

- **GitHub API**: Personal Access Token with `repo` scope
- **Anthropic API**: API key from [console.anthropic.com](https://console.anthropic.com)

## Configuration Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `repo` | GitHub repository (owner/name) | `claude-builders-bounty/claude-builders-bounty` |
| `webhookUrl` | Discord or Slack incoming webhook URL | `https://discord.com/api/webhooks/...` |
| `language` | Output language | `EN` or `FR` |

## Nodes Overview

| Node | Purpose |
|------|---------|
| Cron | Weekly trigger (Fridays 17:00) |
| Set Config | Define repo, webhook, language |
| GitHub Commits | Fetch commits from past week |
| GitHub Issues | Fetch closed issues from past week |
| GitHub PRs | Fetch merged PRs from past week |
| Merge Data | Combine all GitHub data |
| Claude API | Generate narrative summary |
| Discord/Slack Webhook | Send the summary |

## Screenshot

> Include a screenshot of a successful execution here (e.g., `screenshot.png`)