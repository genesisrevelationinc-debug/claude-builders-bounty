# n8n + Claude — Weekly Dev Summary Workflow

Automatically generate and deliver a weekly narrative summary of your GitHub repo's activity using n8n and the Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, go to *Workflows → Import from File* and select `weekly-dev-summary.json`.
2. **Set credentials**: Add your GitHub Personal Access Token, Claude API key, and (optional) Slack/Discord webhook URL in *Settings → Credentials*.
3. **Configure variables**: Open the workflow and edit the *Set Variables* node — set `repoOwner`, `repoName`, `language` (`EN` or `FR`), and `deliveryMethod` (`slack`, `discord`, or `email`).
4. **Activate the workflow**: Toggle the workflow to *Active* — it runs every Friday at 5 PM UTC.
5. **Test manually**: Click *Execute Workflow* to verify, then check your chosen channel for the summary.

## Required Credentials

| Service | Credential Type | How to Obtain |
|---------|----------------|---------------|
| GitHub | Personal Access Token | [GitHub Settings → Developer settings → Personal access tokens](https://github.com/settings/tokens) |
| Claude | API Key | [Anthropic Console](https://console.anthropic.com/settings/keys) |
| Slack (optional) | Webhook URL | [Slack Apps → Incoming Webhooks](https://api.slack.com/messaging/webhooks) |
| Discord (optional) | Webhook URL | [Server Settings → Integrations → Webhooks](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks) |
| SMTP (optional) | SMTP credentials | Your email provider's SMTP settings |

## Workflow Overview

