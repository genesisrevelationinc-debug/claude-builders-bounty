# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of a GitHub repo's activity, powered by n8n and Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in *Settings* → *Credentials*
3. **Configure variables**: Open the workflow and edit the *Set Config* node with your repo, destination, and language
4. **Activate**: Toggle the workflow to *Active* — it runs every Friday at 5 PM
5. **Test**: Click *Execute Workflow* to run manually and verify output

## Configuration

Edit the **Set Config** node to customize:

| Variable | Description | Example |
|----------|-------------|---------|
| `githubRepo` | Target repository | `claude-builders-bounty/claude-builders-bounty` |
| `destination` | Webhook URL for delivery | `https://hooks.slack.com/services/...` |
| `language` | Summary language | `EN` or `FR` |

## What It Does

- **Trigger**: Cron schedule (weekly, Friday 5 PM)
- **Fetch**: Commits, closed issues, and merged PRs from the past 7 days via GitHub API
- **Summarize**: Sends data to Claude API (`claude-sonnet-4-20250514`) for narrative generation
- **Deliver**: Posts the summary to your configured Slack/Discord webhook or email

## Required Credentials

- **GitHub API**: Personal Access Token with `repo` scope
- **Anthropic API**: API key from [console.anthropic.com](https://console.anthropic.com)

## Delivery Options

The workflow defaults to **Slack/Discord webhook**. To switch to **email**:
1. Replace the *HTTP Request* node with an *Email* node
2. Configure SMTP credentials in n8n settings

## Screenshot

![Successful Execution](screenshot.png)

*Include a screenshot of a successful execution from your n8n instance here.*