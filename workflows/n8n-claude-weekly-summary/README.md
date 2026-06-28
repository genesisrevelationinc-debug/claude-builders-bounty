# n8n + Claude — Automated Weekly Dev Summary

An n8n workflow that fetches weekly GitHub activity and generates a narrative summary via Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, click *Workflows → Import → From File* and select `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API Key in *Settings → Credentials*
3. **Configure variables**: Open the workflow and edit the `Configuration` node — set repo, channel webhook, and language
4. **Activate**: Toggle the workflow to *Active* in the top-right corner
5. **Test run**: Click *Execute Workflow* to verify, or wait for the scheduled Friday 5 PM trigger

## Required Credentials

- **GitHub API**: Personal Access Token with `repo` scope
- **Anthropic API**: API key from [console.anthropic.com](https://console.anthropic.com)

## Delivery Options

The workflow supports **Discord webhook** by default (configurable in the `Configuration` node). To use Slack instead, replace the Discord node with a Slack node and update the webhook URL.

## Workflow Nodes

| Node | Purpose |
|------|---------|
| Cron Trigger | Weekly schedule (Fridays at 5 PM) |
| Configuration | Centralized variables (repo, language, destination) |
| GitHub Commits | Fetch commits from the past 7 days |
| GitHub Issues | Fetch closed issues from the past 7 days |
| GitHub PRs | Fetch merged PRs from the past 7 days |
| Merge Data | Combine all GitHub data into one object |
| Claude API | Generate narrative summary |
| Discord Webhook | Deliver the summary |

## Language Support

Set `language` in the Configuration node to `EN` or `FR`. The Claude prompt adapts automatically.

## Screenshot

> Include a screenshot of a successful execution here after testing.
> Example: `assets/success-execution.png`