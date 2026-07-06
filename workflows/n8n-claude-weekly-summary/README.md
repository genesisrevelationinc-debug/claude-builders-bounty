# n8n + Claude — Weekly Dev Summary Workflow

Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, click *Import* → *From File* → select `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub token and Claude API key in *Credentials*
3. **Configure variables**: Edit the *Set Config* node — set `repo`, `channel`, and `language`
4. **Set destination**: In the *Deliver Summary* node, enter your email/Discord/Slack webhook URL
5. **Activate**: Toggle the workflow to *Active* — runs every Friday at 5pm

## What It Does

- Triggers weekly (cron: `0 17 * * 5`)
- Fetches commits, closed issues, and merged PRs from the past 7 days via GitHub API
- Sends data to Claude API (`claude-sonnet-4-20250514`) for narrative generation
- Delivers the summary via your chosen channel (email, Discord, or Slack webhook)

## Configurable Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `repo` | GitHub repository (owner/repo) | `claude-builders-bounty/claude-builders-bounty` |
| `channel` | Delivery destination | `dev-updates` or email address |
| `language` | Summary language | `EN` or `FR` |

## Required Credentials

- **GitHub API**: Personal access token with `repo` scope
- **Claude API**: Anthropic API key from [console.anthropic.com](https://console.anthropic.com)

## Testing

1. Click *Execute Workflow* manually in n8n
2. Check your destination channel for the summary
3. Review execution data in the n8n editor for debugging

## Screenshot

![Successful Execution](screenshot.png)

---

*Created for [Claude Builders Bounty](https://github.com/claude-builders-bounty/claude-builders-bounty)*
