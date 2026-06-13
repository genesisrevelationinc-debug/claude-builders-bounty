# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of GitHub repo activity using n8n + Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, click ⚙️ → Import → From File → select `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in n8n Credentials
3. **Configure variables**: Open the "Set Config" node and edit: GitHub repo, Slack/Discord webhook URL, language (EN/FR)
4. **Activate workflow**: Toggle the workflow to "Active" — it runs Fridays at 5pm
5. **Test manually**: Click "Execute Workflow" to verify, then check your channel for the summary

## Required Credentials

- **GitHub API**: Personal Access Token with `repo` scope
- **Anthropic**: API key from [console.anthropic.com](https://console.anthropic.com)

## Configurable Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `githubRepo` | Full repo path | `claude-builders-bounty/claude-builders-bounty` |
| `webhookUrl` | Slack/Discord incoming webhook | `https://hooks.slack.com/services/...` |
| `language` | Summary language | `EN` or `FR` |

## Delivery

This workflow uses **Slack/Discord webhooks** for delivery. The HTTP Request node posts the formatted summary to your configured channel.

## Claude Model

Uses `claude-sonnet-4-20250514` for high-quality narrative generation.

## Workflow Overview

