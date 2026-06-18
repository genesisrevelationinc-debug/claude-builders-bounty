# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of a GitHub repo's activity, powered by n8n and Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, go to *Workflows → Import from File* and select `workflow.json`
2. **Set credentials**: Add your GitHub Personal Access Token, Claude API key, and webhook URL (Discord/Slack) or SMTP credentials in n8n *Settings → Credentials*
3. **Configure variables**: Open the *Set Variables* node and set `repoOwner`, `repoName`, `language` (EN/FR), and `destinationChannel`
4. **Activate the workflow**: Toggle the workflow to *Active* in the n8n editor
5. **Verify**: Manually execute the workflow and check your destination channel for the summary

## Required Credentials

| Service | Credential Type | How to Obtain |
|---------|----------------|---------------|
| GitHub | Personal Access Token | [GitHub Settings → Developer settings → Personal access tokens](https://github/settings/tokens) — needs `repo` scope |
| Claude | API Key | Anthropic Console → [API Keys](https://console.anthropic.com/settings/keys) |
| Discord/Slack | Webhook URL | Discord: Server Settings → Integrations → Webhooks; Slack: Apps → Incoming Webhooks |

## Workflow Overview

