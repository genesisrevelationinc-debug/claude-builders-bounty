# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of GitHub repo activity using n8n + Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, click *Import* → *From File* → select `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in n8n *Credentials*
3. **Configure variables**: Open the *Set Config* node and edit: `githubRepo`, `discordWebhookUrl` (or `slackWebhookUrl`), `language` (`EN` or `FR`)
4. **Activate**: Toggle the workflow to *Active* — it runs Fridays at 5 PM
5. **Test**: Click *Execute Workflow* to run manually and verify output in your Discord/Slack channel

## Delivery

By default, the workflow sends summaries to **Discord** via webhook. To use Slack instead, change the `httpRequest` node URL to your Slack webhook and adjust the payload format in the *Format Message* node.

## Required Credentials

- **GitHub API**: Personal Access Token with `repo` scope
- **Anthropic API**: API key from [console.anthropic.com](https://console.anthropic.com)

## Workflow Overview

