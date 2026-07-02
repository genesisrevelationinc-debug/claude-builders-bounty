# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of a GitHub repo's activity using n8n + Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, click *Workflows → Import from File* and select `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in *Settings → Credentials*
3. **Configure variables**: Open the *Set Variables* node and set `repo`, `channelWebhook`, and `language` (EN/FR)
4. **Activate**: Toggle the workflow to *Active* — it runs Fridays at 5pm UTC
5. **Test**: Click *Execute Workflow* to run manually and verify output

## Delivery

The workflow sends summaries via **Discord webhook** (configurable to Slack/Email by changing the HTTP Request node).

## Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `repo` | GitHub repository (owner/repo) | `claude-builders-bounty/claude-builders-bounty` |
| `channelWebhook` | Discord webhook URL | `https://discord.com/api/webhooks/...` |
| `language` | Summary language | `EN` or `FR` |

## Screenshot

![Successful execution](screenshot.png)

*Include a screenshot of a successful execution from your n8n instance here.*

## Files

- `weekly-dev-summary.json` — n8n workflow export
- `README.md` — this file
