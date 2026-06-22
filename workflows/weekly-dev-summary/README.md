# n8n Weekly Dev Summary Workflow

Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`

2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in *Settings* → *Credentials*

3. **Configure variables**: Open the workflow and edit the `Configuration` node with your repo, channel, and language

4. **Activate the workflow**: Toggle the workflow to *Active* — it runs every Friday at 5 PM

5. **Test it**: Click *Execute Workflow* to run manually and verify output

---

## What It Does

- **Trigger**: Weekly cron (Fridays at 5:00 PM)
- **Fetches**: Commits, closed issues, and merged PRs from the past 7 days
- **Summarizes**: Sends data to Claude API (`claude-sonnet-4-20250514`) for a narrative summary
- **Delivers**: Posts summary to a Discord webhook (configurable)

## Required Credentials

| Service | Type | How to Get |
|---------|------|-----------|
| GitHub | Personal Access Token | [GitHub Settings → Developer Settings → Tokens](https://github.com/settings/tokens) |
| Anthropic | API Key | [Anthropic Console](https://console.anthropic.com) |

## Configuration Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `githubRepo` | Full repo path | `claude-builders-bounty/claude-builders-bounty` |
| `discordWebhook` | Discord webhook URL | `https://discord.com/api/webhooks/...` |
| `language` | Summary language | `EN` or `FR` |

## Screenshot

![Successful Execution](screenshot.png)

---

## License

MIT