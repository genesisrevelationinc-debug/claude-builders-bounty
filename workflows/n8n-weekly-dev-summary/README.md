# n8n Weekly Dev Summary Workflow

Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in *Settings* → *Credentials*
3. **Configure variables**: Open the workflow and edit the `Configuration` node with your repo, channel, and language
4. **Activate**: Toggle the workflow to *Active* in the top-right corner
5. **Test run**: Click *Execute Workflow* to verify, or wait for the weekly cron trigger (Fridays at 5pm)

## Required Credentials

- **GitHub API**: Personal Access Token with `repo` scope
- **Anthropic API**: API key from [console.anthropic.com](https://console.anthropic.com)

## Configurable Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `githubRepo` | Target repository (format: `owner/repo`) | `claude-builders-bounty/claude-builders-bounty` |
| `destinationChannel` | Email address or webhook URL | `your-channel@example.com` |
| `language` | Output language (`EN` or `FR`) | `EN` |
| `deliveryMethod` | `email` or `webhook` | `email` |

## What It Does

1. Triggers every Friday at 5:00 PM
2. Fetches commits, closed issues, and merged PRs from the past 7 days
3. Sends data to Claude API (`claude-sonnet-4-20250514`) for narrative generation
4. Delivers the summary via email or webhook

## Delivery Options

- **Email**: Configure SMTP credentials in n8n; set `deliveryMethod` to `email`
- **Webhook (Discord/Slack)**: Paste your webhook URL in `destinationChannel`; set `deliveryMethod` to `webhook`

## Screenshot

![Successful Execution](screenshot-success.png)

## Files

- `weekly-dev-summary.json` — Importable n8n workflow
- `README.md` — This file