# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of GitHub repo activity using n8n + Claude API.

## Setup (5 steps)

### 1. Import the workflow
In n8n, click **Add Workflow** → **Import from File** → select `weekly-dev-summary.json`.

### 2. Set credentials
Create credentials in n8n for:
- **GitHub API** (personal access token with `repo` scope)
- **Anthropic API** (Claude API key from [console.anthropic.com](https://console.anthropic.com))

### 3. Configure variables
Open the workflow, click the **⚙️ Settings** tab, and set:
- `githubRepo`: e.g. `owner/repo-name`
- `destinationWebhook`: your Discord/Slack webhook URL
- `language`: `EN` or `FR`

### 4. Activate the workflow
Toggle the workflow to **Active**. It runs every Friday at 5 PM UTC.

### 5. Test manually
Click **Execute Workflow** to run a test. Check your Discord/Slack channel for the summary.

---

## Delivery: Discord Webhook

This workflow delivers summaries via **Discord webhook**. To use Slack instead, replace the Discord node with an HTTP Request node pointing to your Slack webhook URL with the same payload structure.

## Screenshot

![Successful execution](screenshot.png)

> *Include a screenshot of your n8n execution here after testing.*

---

## License

MIT