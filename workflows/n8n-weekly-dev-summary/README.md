# n8n Weekly Dev Summary Workflow

Automated n8n workflow that generates a weekly narrative summary of a GitHub repo's activity using the Claude API.

## What It Does

- **Trigger**: Runs every Friday at 5:00 PM
- **Fetches**: Commits, closed issues, and merged PRs from the past week via GitHub API
- **Summarizes**: Sends data to Claude API (`claude-sonnet-4-20250514`) for a narrative summary
- **Delivers**: Posts the summary to a Discord webhook (configurable)
- **Languages**: Supports EN and FR

## Setup (5 Steps)

1. **Import** `workflow.json` into your n8n instance (Settings → Import)
2. **Set credentials**: Add your GitHub token and Claude API key in n8n credentials
3. **Configure variables**: Edit the "Set Config" node with your repo, Discord webhook, and language (EN/FR)
4. **Activate** the workflow and enable the cron trigger
5. **Test** manually with the "Execute Workflow" button

## Required Credentials

- GitHub Personal Access Token (classic, with `repo` scope)
- Anthropic API Key (Claude API)

## Configurable Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `githubRepo` | Full repo name | `claude-builders-bounty/claude-builders-bounty` |
| `discordWebhook` | Discord webhook URL | `https://discord.com/api/webhooks/...` |
| `language` | Summary language | `EN` or `FR` |

## Output Example

The workflow produces a narrative summary like:

> **Weekly Dev Summary for `claude-builders-bounty`**
>
> This week saw 12 commits, 3 closed issues, and 2 merged PRs. Key highlights include...

---

*Tested on n8n v1.50.0*