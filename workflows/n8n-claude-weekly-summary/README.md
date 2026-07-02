# n8n + Claude Weekly Dev Summary Workflow

Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API Key in *Settings* → *Credentials*
3. **Configure variables**: Edit the *Set Config* node — set `repoOwner`, `repoName`, `webhookUrl`, and `language` (EN/FR)
4. **Activate**: Toggle the workflow to *Active* in the top-right corner
5. **Test**: Click *Execute Workflow* to run manually, or wait for the weekly cron trigger (Fridays at 5pm)

## Delivery Options

The workflow sends summaries via **Discord webhook** by default. To use Slack instead, change the `webhookUrl` to your Slack incoming webhook URL. For email delivery, replace the *HTTP Request* node with an *Email* node (SMTP credentials required).

## Required Credentials

- **GitHub API**: Personal Access Token with `repo` scope
- **Anthropic API**: API key from [console.anthropic.com](https://console.anthropic.com)

## Workflow Overview

