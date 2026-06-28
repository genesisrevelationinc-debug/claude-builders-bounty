# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of a GitHub repo's activity, powered by n8n + Claude API.

## Setup (5 steps)

1. **Import** `weekly-dev-summary.json` into your n8n instance (Settings → Workflows → Import)
2. **Configure credentials**: Add your GitHub Personal Access Token, Claude API Key, and Email (or webhook) credentials in n8n
3. **Set variables**: Open the workflow and edit the `Set Config` node — set `repoOwner`, `repoName`, `language` (EN/FR), and `destination` (email or webhook URL)
4. **Activate** the workflow toggle to enable the weekly cron trigger
5. **Test** manually by clicking "Execute Workflow" — check your destination for the summary

## Features

- **Trigger**: Every Friday at 5:00 PM
- **GitHub Data**: Fetches commits, closed issues, and merged PRs from the past 7 days
- **AI Summary**: Claude `claude-sonnet-4-20250514` generates a narrative summary
- **Delivery**: Email (SMTP) or webhook (Discord/Slack)
- **Languages**: English or French

## Required Credentials

| Service | Type | How to Obtain |
|---------|------|---------------|
| GitHub | Personal Access Token | [GitHub Settings → Developer settings](https://github.com/settings/tokens) |
| Claude | API Key | [Anthropic Console](https://console.anthropic.com/) |
| Email/SMTP | SMTP credentials | Your email provider settings |

## Workflow Nodes

1. **Cron Trigger** — Weekly Friday 5pm
2. **Set Config** — Workflow variables (repo, language, destination)
3. **GitHub Commits** — Fetch commits from past 7 days
4. **GitHub Issues** — Fetch closed issues from past 7 days
5. **GitHub PRs** — Fetch merged PRs from past 7 days
6. **Merge Data** — Combine all activity data
7. **Claude API** — Generate narrative summary
8. **Deliver Summary** — Send via email or webhook

## Screenshot

> Include a screenshot of successful execution here: `screenshot-success.png`