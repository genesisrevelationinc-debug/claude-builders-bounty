# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of GitHub repo activity using n8n + Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, click *Workflows → Import from File* and select `weekly-dev-summary.json`

2. **Set credentials**: Add your *Claude API* and *GitHub API* credentials in n8n *Settings → Credentials*

3. **Configure variables**: Open the workflow and edit the `Set Config` node with your repo, destination, and language

4. **Activate**: Toggle the workflow to *Active* in the top-right corner

5. **Test**: Click *Execute Workflow* or wait for the weekly cron trigger

---

## Configuration Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `githubRepo` | Full repo path | `claude-builders-bounty/claude-builders-bounty` |
| `destination` | Webhook URL or email | `https://hooks.slack.com/services/...` |
| `language` | Summary language | `EN` or `FR` |

---

## Delivery Options

- **Slack/Discord**: Set `destination` to a webhook URL
- **Email**: Configure SMTP credentials and replace the HTTP Request node with an Email node

---

## Screenshot

![Successful Execution](screenshot.png)

---

*Built for the Claude Builders Bounty — MIT License*