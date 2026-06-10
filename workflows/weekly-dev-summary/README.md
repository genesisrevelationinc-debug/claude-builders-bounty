# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of a GitHub repo's activity, powered by Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub Personal Access Token and Claude API key in *Settings* → *Credentials*
3. **Configure variables**: Open the workflow and edit the **Set Config** node — set `repo`, `channelWebhook`, and `language`
4. **Activate**: Toggle the workflow to *Active* in the top-right corner
5. **Test run**: Click *Execute Workflow* to verify, or wait for the scheduled Friday 5 PM run

## Delivery Options

The workflow defaults to **Discord webhook** for delivery. To switch to **Slack**, change the HTTP Request node URL to your Slack incoming webhook. To use **email**, replace the webhook node with an n8n *Send Email* node.

## Required Credentials

- `githubApi`: GitHub Personal Access Token (classic) with `repo` scope
- `claudeApi`: Anthropic API key (starts with `sk-ant-`)

## Workflow Overview

