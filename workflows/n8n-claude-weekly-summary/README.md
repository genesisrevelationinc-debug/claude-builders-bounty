# n8n + Claude Weekly Dev Summary Workflow

Automatically generate and deliver a weekly narrative summary of your GitHub repo's activity using n8n and Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub API token, Claude API key, and email/SMTP or webhook credentials in n8n *Settings* → *Credentials*
3. **Configure variables**: Open the workflow and edit the *Set Config* node — set `repoOwner`, `repoName`, `destinationChannel`, and `language` (EN or FR)
4. **Activate the workflow**: Toggle the workflow to *Active* in the top-right corner
5. **Test manually**: Click *Execute Workflow* to run it once, or wait for the scheduled Friday 5 PM trigger

## Required Credentials

| Service | Credential Type | How to Get |
|---------|---------------|------------|
| GitHub | GitHub API | [Personal Access Token](https://github.com/settings/tokens) with `repo` scope |
| Claude | Anthropic API | [API Key](https://console.anthropic.com/) |
| Email/SMTP | SMTP or SendGrid | Your email provider's SMTP settings |
| **OR** Discord | Webhook URL | [Discord Webhook](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks) |
| **OR** Slack | Webhook URL | [Slack Incoming Webhook](https://api.slack.com/messaging/webhooks) |

## Configuration Variables

All variables are set in the **Set Config** node at the top of the workflow:

- `repoOwner` — GitHub organization or user name
- `repoName` — Repository name
- `destinationChannel` — Email address or webhook URL
- `language` — `EN` or `FR`
- `deliveryMethod` — `email`, `discord`, or `slack`

## What It Does

1. Triggers every Friday at 5:00 PM
2. Fetches commits, closed issues, and merged PRs from the past 7 days
3. Sends the data to Claude API (`claude-sonnet-4-20250514`) for narrative summarization
4. Delivers the formatted summary via your chosen channel

## Screenshot

![Successful Execution](screenshot-success.png)

## License

MIT