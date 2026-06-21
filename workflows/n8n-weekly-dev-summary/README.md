# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary generator using n8n + Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, go to Workflows → Import from File → select `weekly-dev-summary.json`

2. **Set credentials**: Add your GitHub Personal Access Token, Claude API key, and email/SMTP or webhook credentials in n8n Settings → Credentials

3. **Configure variables**: Edit the "Set Variables" node with your repo, destination, and language (EN/FR)

4. **Activate**: Toggle the workflow to "Active" — it runs Fridays at 5pm automatically

5. **Test run**: Click "Execute Workflow" to verify, check execution history for ✅

## Required Credentials

| Service | Type | Notes |
|---------|------|-------|
| GitHub | OAuth2 or Personal Access Token | Needs `repo` scope |
| Claude | API Key | From [Anthropic Console](https://console.anthropic.com) |
| Email/SMTP or Webhook | SMTP or HTTP Request | Choose one delivery method |

## Configurable Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `githubRepo` | Full repo path | `claude-builders-bounty/claude-builders-bounty` |
| `destination` | Email or webhook URL | `https://hooks.slack.com/services/...` |
| `language` | Summary language | `EN` or `FR` |

## Delivery Methods

- **Email**: Configure SMTP credentials, set `destination` to recipient email
- **Slack/Discord**: Set `destination` to webhook URL, workflow auto-detects and formats accordingly

## Claude Model

Uses `claude-sonnet-4-20250514` as specified in bounty requirements.

## Screenshot

![Successful Execution](screenshot.png)

*Include screenshot of successful n8n execution here*