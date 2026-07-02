# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of GitHub repo activity using n8n + Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, click *Workflows → Import → From File* and select `weekly-dev-summary.json`.

2. **Set credentials**: Add your *Anthropic API* and *GitHub API* credentials in n8n *Settings → Credentials*.

3. **Configure variables**: Open the workflow and edit the **Set Config** node with your repo, destination, and language.

4. **Set up delivery**: Configure the **Email** or **Webhook** node with your SMTP/Discord/Slack details.

5. **Activate**: Toggle the workflow to *Active* — it runs every Friday at 5 PM.

---

## Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `githubRepo` | Full repo path | `owner/repo-name` |
| `destination` | Email or webhook URL | `https://discord.com/api/webhooks/...` |
| `language` | Summary language | `EN` or `FR` |

## Nodes Overview

- **Cron Trigger**: Weekly Friday 17:00
- **GitHub Commits**: Fetch commits from past 7 days
- **GitHub Issues**: Fetch closed issues from past 7 days
- **GitHub PRs**: Fetch merged PRs from past 7 days
- **Aggregate Data**: Combine all activity
- **Claude API**: Generate narrative summary (`claude-sonnet-4-20250514`)
- **Deliver**: Send via email or webhook

## Testing

Run the workflow manually in n8n and check the execution output. A successful run shows green checkmarks on all nodes.

---

## Screenshot

> Include a screenshot of your successful n8n execution here and name it `screenshot.png`.

*Built for the Claude Builders Bounty — MIT License*