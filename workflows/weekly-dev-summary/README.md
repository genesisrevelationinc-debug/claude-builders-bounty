# n8n Weekly Dev Summary Workflow

Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, click ⚙️ → Import → paste `workflow.json`
2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in n8n credentials
3. **Configure variables**: Edit the `Set Config` node — set `repo`, `owner`, `webhookUrl`, and `language` (EN/FR)
4. **Activate**: Toggle the workflow to "Active"
5. **Test**: Click "Execute Workflow" or wait for the Friday 5pm cron trigger

## Delivery Options

By default, this workflow sends to a **Discord webhook**. To use Slack instead, change the HTTP Request node URL to your Slack webhook. For email, replace the final node with an n8n Email node.

## Required Credentials

- **GitHub API**: Personal Access Token with `repo` scope
- **Anthropic**: API key from [console.anthropic.com](https://console.anthropic.com)

## Workflow Overview

