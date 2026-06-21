# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of a GitHub repo's activity, powered by n8n and Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in *Settings* → *Credentials*
3. **Configure variables**: Open the *Set Config* node and edit: `repoOwner`, `repoName`, `destinationWebhook`, `language`
4. **Activate the workflow**: Toggle the workflow to *Active* — it runs every Friday at 5 PM
5. **Test manually**: Click *Execute Workflow* to verify, then check your email/Discord for the summary

## Delivery Options

The workflow defaults to **Discord webhook**. To use Slack instead, replace the Discord node with a Slack node and update `destinationWebhook`. For email, replace with an Email node and configure SMTP credentials.

## Required Credentials

- **GitHub API**: Personal Access Token with `repo` scope
- **Anthropic API**: API key from [console.anthropic.com](https://console.anthropic.com)

## Workflow Overview

