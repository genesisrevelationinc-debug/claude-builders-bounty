# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of a GitHub repo's activity, powered by n8n + Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, click *Add Workflow* → *Import from File* → select `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in n8n *Credentials*
3. **Configure variables**: Open the *Set Config* node and edit: `githubRepo`, `discordWebhookUrl` (or `slackWebhookUrl`), `language` (`EN` or `FR`)
4. **Set the cron schedule**: In the *Weekly Cron* node, adjust to your preferred day/time (default: Friday 17:00)
5. **Activate**: Toggle the workflow to *Active* and run a manual test

## What It Does

- Triggers weekly via cron
- Fetches commits, closed issues, and merged PRs from the past 7 days
- Sends data to Claude API (`claude-sonnet-4-20250514`) for narrative summarization
- Delivers the summary via Discord webhook (configurable to Slack or email)

## Required Credentials

- **GitHub Personal Access Token** (classic, with `repo` scope)
- **Anthropic API Key** (from [console.anthropic.com](https://console.anthropic.com))

## Configurable Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `githubRepo` | Target GitHub repository (format: `owner/repo`) | `claude-builders-bounty/claude-builders-bounty` |
| `discordWebhookUrl` | Discord webhook URL for delivery | — |
| `slackWebhookUrl` | Slack webhook URL (alternative) | — |
| `language` | Summary language: `EN` or `FR` | `EN` |

## Nodes Overview

| Node | Purpose |
|------|---------|
| Weekly Cron | Trigger every Friday at 17:00 |
| Set Config | Define repo, webhook, language |
| GitHub Commits | Fetch commits from past 7 days |
| GitHub Issues | Fetch closed issues from past 7 days |
| GitHub PRs | Fetch merged PRs from past 7 days |
| Merge Data | Combine all activity data |
| Claude API | Generate narrative summary |
| Send to Discord/Slack | Deliver the summary |

## Screenshot

> 📸 *Run the workflow manually in n8n and capture the execution screenshot for the PR.*

## License

MIT