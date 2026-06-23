# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of a GitHub repo's activity, powered by n8n and Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`

2. **Set credentials**: Open the workflow, then in *Settings* → *Variables* add:
   - `githubToken` — [GitHub Personal Access Token](https://github.com/settings/tokens) with `repo` scope
   - `claudeApiKey` — [Anthropic API key](https://console.anthropic.com)

3. **Configure the repo**: Edit the *Set Config* node and set:
   - `repoOwner` — GitHub organization or user name
   - `repoName` — repository name
   - `language` — `EN` or `FR`
   - `destination` — email address **or** webhook URL (Discord/Slack)

4. **Choose delivery method**: In the *Route Delivery* node, set `deliveryType` to `email` or `webhook`

5. **Activate**: Toggle the workflow to *Active* — it runs every Friday at 5 PM

## Delivery Options

| Method | Configuration |
|--------|---------------|
| Email | Set `destination` to your email address; configure SMTP credentials in the *Send Email* node |
| Webhook | Set `destination` to a Discord/Slack webhook URL; the *HTTP Request* node will POST the summary |

## Workflow Overview

