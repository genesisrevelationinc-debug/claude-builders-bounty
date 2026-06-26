# n8n Weekly Dev Summary Workflow

Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`

2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API Key in n8n *Settings* → *Credentials*

3. **Configure variables**: Open the workflow and edit the *Set Variables* node with your repo, destination, and language

4. **Activate the workflow**: Toggle the workflow to *Active* — it runs every Friday at 5 PM

5. **Test it**: Click *Execute Workflow* to run manually and verify output

---

## Required Credentials

| Service | Credential Type | How to Get |
|---------|----------------|------------|
| GitHub | Personal Access Token | [Settings → Developer settings → Personal access tokens](https://github.com/settings/tokens) |
| Anthropic | API Key | [Console → API keys](https://console.anthropic.com/settings/keys) |

## Configurable Variables

Edit the **Set Variables** node to customize:

| Variable | Description | Example |
|----------|-------------|---------|
| `githubRepo` | Full repo path | `owner/repo-name` |
| `destinationWebhook` | Email or webhook URL | `https://hooks.slack.com/services/...` |
| `language` | Output language | `EN` or `FR` |

## Delivery Options

The workflow supports **Slack**, **Discord**, and **Email** out of the box. Set your `destinationWebhook` to:
- Slack incoming webhook URL
- Discord webhook URL (adds `/slack` suffix automatically)
- SMTP settings for email (configure *Send Email* node instead)

## Screenshot

> 📸 *Include a screenshot of a successful execution here after testing*

---