# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of GitHub repo activity using n8n + Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, click *Workflows* → *Import from File* → select `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in *Settings* → *Credentials*
3. **Configure variables**: Open the *Set Config* node and edit: `githubRepo`, `discordWebhookUrl` (or `emailTo`), `language` (`EN` or `FR`)
4. **Activate**: Toggle the workflow to *Active* — it runs Fridays at 5 PM
5. **Test manually**: Click *Execute Workflow* to verify — check execution history for ✅

## Delivery Options

- **Discord** (default): Set `discordWebhookUrl` in the *Set Config* node; leave `emailTo` empty
- **Email**: Set `emailTo` and clear `discordWebhookUrl`; configure SMTP credentials in n8n

## Required Credentials

| Service | Credential Type | How to Get |
|---------|----------------|------------|
| GitHub | `githubApi` | [Settings → Developer → PAT](https://github.com/settings/tokens) with `repo` scope |
| Anthropic | `anthropicApi` | [Console → API Keys](https://console.anthropic.com/settings/keys) |
| SMTP (optional) | `smtp` | Your email provider settings |

## Workflow Overview

