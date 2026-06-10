# n8n Weekly Dev Summary Workflow

Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.

## Setup (5 steps)

1. **Import** `workflow.json` into your n8n instance (Settings → Workflows → Import)
2. **Configure** credentials: GitHub API (optional, for public repos) and Anthropic API
3. **Set** the `repo` parameter to your `owner/repo` and choose `language` (EN/FR)
4. **Configure** delivery: set `webhookUrl` for Discord/Slack, or `email` for SMTP
5. **Activate** the workflow — it runs Fridays at 5 PM automatically

## Required Credentials

| Service | Credential Type | How to Get |
|---------|----------------|------------|
| Anthropic | API Key | [console.anthropic.com](https://console.anthropic.com) |
| GitHub | Personal Access Token | [github.com/settings/tokens](https://github.com/settings/tokens) (optional for public repos) |
| SMTP (email) | SMTP credentials | Your email provider settings |

## Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `repo` | GitHub repository (owner/repo format) | `claude-builders-bounty/claude-builders-bounty` |
| `language` | Output language: `EN` or `FR` | `EN` |
| `webhookUrl` | Discord/Slack webhook URL | — |
| `email` | Destination email address | — |

## Delivery Options

- **Discord/Slack**: Set `webhookUrl` to your channel's webhook URL
- **Email**: Configure SMTP credentials and set the `email` parameter

## Testing

1. Set all parameters in the workflow settings
2. Click "Execute Workflow" to run manually
3. Check your delivery channel for the summary

## Screenshot

![Successful Execution](screenshot.png)

---

*Built for the Claude Builders Bounty — MIT License*