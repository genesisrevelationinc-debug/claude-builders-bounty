# n8n + Claude — Automated Weekly Dev Summary

Weekly narrative summary of GitHub repo activity, powered by n8n and Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`
2. **Set credentials**: Add your *GitHub API* and *Anthropic API* credentials in n8n
3. **Configure variables**: Open the workflow, edit the `Set Config` node — set `repo`, `channelWebhook`, and `language`
4. **Activate**: Toggle the workflow to *Active* — it runs Fridays at 5 PM
5. **Test**: Click *Execute Workflow* to run manually and verify output

## Required Credentials

- **GitHub API**: Personal access token with `repo` scope
- **Anthropic API**: API key from [Anthropic console](https://console.anthropic.com)

## Configurable Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `repo` | GitHub `owner/repo` to summarize | `claude-builders-bounty/claude-builders-bounty` |
| `channelWebhook` | Discord/Slack webhook URL | `https://hooks.slack.com/services/...` |
| `language` | Output language: `EN` or `FR` | `EN` |

## What It Does

1. Triggers weekly (Friday 5 PM via cron)
2. Fetches commits, closed issues, and merged PRs from the past 7 days
3. Sends data to Claude API (`claude-sonnet-4-20250514`) for narrative generation
4. Posts the summary to your configured Discord/Slack webhook

## Testing

![Successful Execution](screenshot.png)

*Screenshot: Successful workflow execution showing data fetch, Claude API call, and webhook delivery.*

## Files

- `weekly-dev-summary.json` — Importable n8n workflow
- `README.md` — This file