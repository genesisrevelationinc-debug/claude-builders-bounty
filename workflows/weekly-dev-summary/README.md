# n8n Weekly Dev Summary Workflow

Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, click *Workflows* → *Import from File* → select `weekly-dev-summary.json`

2. **Set credentials**: Add your GitHub Personal Access Token, Claude API key, and webhook/email credentials in n8n *Settings* → *Credentials*

3. **Configure variables**: Open the workflow and edit the *Set Variables* node with your repo, destination, and language

4. **Activate the workflow**: Toggle the workflow to *Active* in the top-right corner

5. **Test manually**: Click *Execute Workflow* to run immediately, or wait for the Friday 5pm cron trigger

---

## Required Credentials

| Service | Type | How to get |
|---------|------|-----------|
| GitHub | Personal Access Token | [Settings → Developer settings → Tokens](https://github.com/settings/tokens) |
| Claude | API Key | [Console → API Keys](https://console.anthropic.com/settings/keys) |
| Discord/Slack | Webhook URL | Channel settings → Integrations → Webhooks |

## Configurable Variables

Edit the **Set Variables** node to customize:

| Variable | Description | Example |
|----------|-------------|---------|
| `githubRepo` | Target repository | `owner/repo-name` |
| `destinationWebhook` | Discord/Slack webhook URL | `https://discord.com/api/webhooks/...` |
| `language` | Summary language | `EN` or `FR` |

## What It Does

1. Triggers every Friday at 5:00 PM
2. Fetches commits, closed issues, and merged PRs from the past 7 days
3. Sends data to Claude API for narrative generation
4. Posts the formatted summary to your configured channel

## Claude Model

Uses `claude-sonnet-4-20250514` for high-quality, structured summaries.

## Troubleshooting

- **No data returned**: Ensure your GitHub token has `repo` scope for private repos
- **Claude API errors**: Verify your API key and check [Anthropic status](https://status.anthropic.com)
- **Webhook not firing**: Test the webhook URL with `curl` before configuring

---

*Created for [Claude Builders Bounty](https://github.com/claude-builders-bounty/claude-builders-bounty)*
