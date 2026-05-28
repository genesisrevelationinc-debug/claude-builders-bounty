# Weekly Dev Summary — n8n Workflow

Automated weekly narrative summary of a GitHub repo's activity, powered by n8n + Claude API.

## Setup (5 steps)

1. **Import the workflow**
   - In n8n, go to *Workflows → Import from File* and select `weekly-dev-summary.json`

2. **Set your credentials**
   - *GitHub API* — create a [Personal Access Token](https://github.com/settings/tokens) with `repo` scope
   - *Claude API* — create an [Anthropic API key](https://console.anthropic.com/settings/keys)
   - *Email (SMTP)* or *Webhook* — configure based on your chosen delivery method

3. **Configure workflow variables**
   - Open the workflow, click *Settings → Variables*, and set:
     - `githubRepo` — e.g., `owner/repo-name`
     - `destinationChannel` — email address or webhook URL
     - `language` — `en` or `fr`

4. **Activate the workflow**
   - Toggle the workflow to *Active* — it runs every Friday at 17:00 UTC

5. **Verify execution**
   - Click *Execute Workflow* manually or wait for the cron trigger
   - Check your email/Discord/Slack for the summary

## Delivery Methods

| Method | Configuration |
|--------|---------------|
| **Email** (default) | SMTP credentials + `destinationChannel` = email address |
| **Discord** | Webhook URL as `destinationChannel`, enable Discord node |
| **Slack** | Webhook URL as `destinationChannel`, enable Slack node |

To switch methods, disable the unused delivery node and enable your preferred one.

## Workflow Overview

