# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of GitHub repo activity using n8n + Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, go to *Workflows* → *Import from File* → select `workflow.json`
2. **Set credentials**: Add your GitHub Personal Access Token, Claude API key, and Slack/Discord webhook URL in n8n *Credentials*
3. **Configure variables**: Edit the *Set Config* node — set `repo`, `channelWebhook`, and `language` (`EN` or `FR`)
4. **Activate**: Toggle the workflow to *Active* in the top-right corner
5. **Verify**: Click *Execute Workflow* to test, or wait for the Friday 5pm cron trigger

## Delivery Options

The workflow uses a **Slack/Discord webhook** by default. To switch to **email**, replace the *HTTP Request* node with an *Email* node (SMTP credentials required).

## Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `repo` | GitHub `owner/repo` | `claude-builders-bounty/claude-builders-bounty` |
| `channelWebhook` | Slack/Discord incoming webhook URL | `https://hooks.slack.com/services/...` |
| `language` | Summary language | `EN` or `FR` |

## Required Credentials

- **GitHub Personal Access Token** (classic or fine-grained, with `repo` scope)
- **Anthropic API Key** (Claude API)
- **Slack/Discord Webhook URL** (or SMTP for email)

## Workflow Overview

