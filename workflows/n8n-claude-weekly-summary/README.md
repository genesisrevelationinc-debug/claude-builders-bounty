# n8n + Claude Weekly Dev Summary Workflow

Automatically generate and deliver a weekly narrative summary of GitHub repo activity using n8n and Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, go to *Workflows → Import from File* and select `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API Key in *Settings → Credentials*
3. **Configure variables**: Open the `Configuration` node and set your repo, destination, and language
4. **Activate the workflow**: Toggle the workflow to *Active* — it runs Fridays at 5 PM
5. **Test execution**: Click *Execute Workflow* to run manually and verify output

## Required Credentials

| Service | Credential Type | How to Obtain |
|---------|----------------|---------------|
| GitHub | `githubApi` | [Personal Access Token](https://github.com/settings/tokens) with `repo` scope |
| Anthropic | `anthropicApi` | [API Key](https://console.anthropic.com/settings/keys) |

## Configuration Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `repoOwner` | GitHub repository owner | `claude-builders-bounty` |
| `repoName` | GitHub repository name | `claude-builders-bounty` |
| `destination` | Webhook URL for delivery | `https://hooks.slack.com/services/...` |
| `language` | Summary language (`EN` or `FR`) | `EN` |

## Delivery Options

The workflow uses an **HTTP Request** node for webhook delivery. Configure for:
- **Slack**: Use Incoming Webhook URL
- **Discord**: Use Discord Webhook URL
- **Email**: Replace with n8n *Send Email* node using your SMTP credentials

## Workflow Overview

