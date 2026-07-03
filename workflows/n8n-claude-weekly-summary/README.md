# n8n + Claude Weekly Dev Summary Workflow

Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, go to *Workflows* → *Import* → *From File* and select `workflow.json`
2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API Key in n8n *Settings* → *Credentials*
3. **Configure variables**: Open the workflow and edit the *Set Config* node with your repo, channel, and language
4. **Activate**: Toggle the workflow to *Active* in the top-right corner
5. **Test**: Click *Execute Workflow* to run manually, or wait for the Friday 5pm cron trigger

## Required Credentials

- **GitHub API**: Personal Access Token with `repo` scope
optionally `public_repo` for public repos
- **Anthropic API**: API key from [console.anthropic.com](https://console.anthropic.com)

## Configurable Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `githubRepo` | Full repo path | `claude-builders-bounty/claude-builders-bounty` |
| `destinationWebhook` | Email/Discord/Slack webhook URL | `https://hooks.slack.com/services/...` |
| `language` | Summary language | `EN` or `FR` |

## Delivery Options

The workflow uses a **Discord/Slack webhook** by default. To switch to **email**:
1. Replace the *Send to Discord* node with an *Email (SMTP)* node
2. Configure SMTP credentials in n8n *Settings* → *Credentials*

## Workflow Overview

