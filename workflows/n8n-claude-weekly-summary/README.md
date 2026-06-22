# n8n + Claude Weekly Dev Summary Workflow

Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, go to **Workflows → Import from File** and select `claude-weekly-summary.json`

2. **Set credentials**: Add your **GitHub API** token and **Anthropic API** key in n8n **Settings → Credentials**

3. **Configure variables**: Open the workflow and edit the **Set Config** node with your repo, destination, and language

4. **Set up delivery**: Configure the **Send Email** or **HTTP Request** (webhook) node with your destination details

5. **Activate**: Toggle the workflow to **Active** — it runs every Friday at 5 PM

## Configurable Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `githubRepo` | Target repository | `owner/repo-name` |
| `destination` | `email` or `webhook` | `webhook` |
| `webhookUrl` | Discord/Slack webhook URL | `https://hooks.slack.com/...` |
| `language` | Summary language | `EN` or `FR` |
| `emailTo` | Recipient email (if email) | `dev@example.com` |

## What It Does

- Fetches commits, closed issues, and merged PRs from the past 7 days
- Sends data to Claude API (`claude-sonnet-4-20250514`) for narrative generation
- Delivers the summary via email or webhook

## Screenshot

![Successful Execution](screenshot.png)

*Include a screenshot of your successful n8n execution here.*

## Requirements

- n8n instance (cloud or self-hosted)
- GitHub API token (no special scopes needed for public repos; `repo` for private)
- Anthropic API key
- Email SMTP or webhook URL for delivery

## License

MIT