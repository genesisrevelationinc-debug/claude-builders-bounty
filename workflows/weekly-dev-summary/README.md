# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of GitHub repo activity using n8n + Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, click *Workflows → Import from File* and select `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in *Settings → Credentials*
3. **Configure variables**: Open the *Set Variables* node and set your `repo`, `channelWebhook`, and `language` (EN/FR)
4. **Activate**: Toggle the workflow to *Active* in the top-right corner
5. **Verify**: Click *Execute Workflow* to test, or wait for the weekly cron trigger

## Delivery Options

The workflow supports **Discord/Slack webhook** by default. To switch to email:
- Replace the *HTTP Request* node with an *Email (SMTP)* node
- Use the same `{{ $json.summary }}` expression in the body

## Required Credentials

| Service | Credential Type |
|---------|-----------------|
| GitHub | `githubApi` — Personal Access Token with `repo` scope |
| Anthropic | `anthropicApi` — API key from [console.anthropic.com](https://console.anthropic.com) |

## Workflow Overview

