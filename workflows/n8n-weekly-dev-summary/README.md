# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of a GitHub repo's activity, powered by n8n and Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, go to *Workflows → Import from File* and select `weekly-dev-summary.json`

2. **Set credentials**: Add your GitHub Personal Access Token, Claude API key, and (optional) Slack/Discord webhook URL in *Settings → Credentials*

3. **Configure variables**: Open the workflow and edit the `Configuration` node to set your repo, destination, and language

4. **Activate the workflow**: Toggle the workflow to *Active* — it will run automatically every Friday at 5 PM

5. **Test manually**: Click *Execute Workflow* to verify everything works, then check your chosen destination for the summary

---

## Required Credentials

| Service | How to Obtain |
|---------|---------------|
| GitHub Token | [Settings → Developer settings → Personal access tokens](https://github.com/settings/tokens) — needs `repo` scope |
| Claude API Key | [Anthropic Console](https://console.anthropic.com/settings/keys) |
| Slack Webhook | [Slack Apps → Incoming Webhooks](https://api.slack.com/messaging/webhooks) (optional) |
| Discord Webhook | Server Settings → Integrations → Webhooks (optional) |

## Configuration Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `githubRepo` | Target repository (`owner/repo`) | `claude-builders-bounty/claude-builders-bounty` |
| `destination` | `slack`, `discord`, or `email` | `slack` |
| `webhookUrl` | Webhook URL for Slack/Discord | — |
| `language` | Output language: `EN` or `FR` | `EN` |
| `emailTo` | Recipient email (if email selected) | — |

## Output Example

> **Weekly Dev Summary: `claude-builders-bounty`**
>
> This week saw 12 commits, 3 closed issues, and 2 merged PRs. The team focused on improving the bounty board UI and adding new workflow integrations...

---

*Tested on n8n v1.50.0*