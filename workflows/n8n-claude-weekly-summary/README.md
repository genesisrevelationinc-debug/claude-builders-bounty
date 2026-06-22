# n8n + Claude Weekly Dev Summary Workflow

Automatically generate and deliver a weekly narrative summary of your GitHub repo's activity using n8n and Claude API.

## Setup (5 steps)

### 1. Import the workflow
In n8n, go to **Workflows → Import from File** and select `weekly-dev-summary.json`.

### 2. Set your credentials
- **GitHub API**: Create a [GitHub Personal Access Token](https://github.com/settings/tokens) with `repo` scope. Add it in n8n under **Settings → Credentials → GitHub API**.
- **Claude API**: Get your API key from [Anthropic Console](https://console.anthropic.com). Add it in n8n under **Settings → Credentials → Anthropic API**.

### 3. Configure workflow variables
Open the workflow and edit the **Set Variables** node:
- `githubRepo`: Your target repo (e.g., `owner/repo-name`)
- `destinationWebhook`: Your email/Discord/Slack webhook URL
- `language`: `EN` or `FR`

### 4. Activate the workflow
Toggle the workflow to **Active**. The cron trigger runs every Friday at 5:00 PM UTC.

### 5. Test it
Click **Execute Workflow** to run manually and verify output in your chosen channel.

---

## Delivery Options

| Channel | Webhook URL Format |
|---------|-------------------|
| Email | Use n8n's **Send Email** node (SMTP credentials required) |
| Discord | `https://discord.com/api/webhooks/...` |
| Slack | `https://hooks.slack.com/services/...` |

Replace the **Deliver Summary** node with your preferred channel node, or keep the generic HTTP Request for webhooks.

---

## Requirements

- n8n v1.0+ (self-hosted or cloud)
- GitHub Personal Access Token
- Anthropic API key