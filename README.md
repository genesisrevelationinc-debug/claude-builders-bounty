# Claude Builders Bounty 🤖

> A community bounty board for Claude Code builders.

Building with Claude Code? Have tasks to delegate?
Want to get paid for contributing to AI projects?
You're in the right place.

---

## How it works

**To post a bounty**
1. Open a GitHub issue with a clear description and acceptance criteria
2. Comment `/opire create $XXX` in the issue to set the reward
3. Share the link — contributors will find it

**To claim a bounty**
1. Browse the open issues below
2. Comment `/opire try` in the issue you want to work on
3. Submit a PR — payment is automatic on merge ✅

---

## Active Bounties

| # | Task | Amount | Status |
|---|------|--------|--------|
| [#1](../../issues/1) | SKILL: Generate a CHANGELOG from git history | $50 | 🟢 Open |
| [#2](../../issues/2) | TEMPLATE: CLAUDE.md for a Next.js + SQLite project | $75 | 🟢 Open |
| [#3](../../issues/3) | HOOK: Block destructive bash commands in Claude Code | $100 | 🟢 Open |
| [#4](../../issues/4) | AGENT: PR reviewer with structured Markdown output | $150 | 🟢 Open |
| [#5](../../issues/5) | WORKFLOW: n8n + Claude API — automated weekly dev summary | $200 | 🟢 Open |

---

## Rules

- Tasks must be related to Claude Code or AI tooling
- Every issue must have clear acceptance criteria before a bounty is activated
- Payment is handled by [Opire](https://opire.dev) (Stripe)
- Quality over speed — a solid PR beats a fast one

---

## Community

- 🐦 X: [@ClaudeBounty](https://x.com/ClaudeBounty)
- 📧 Contact: claudebounty@gmail.com

---

# Weekly Development Summary Workflow

This n8n workflow automatically generates a weekly narrative summary of GitHub repository activity using the Claude API.

## Setup Instructions

1. **Import the Workflow**: Import the `claude-weekly-summary.json` file into your n8n instance.
2. **Configure GitHub Token**: Add your GitHub personal access token in the GitHub node credentials.
3. **Configure Claude API Key**: Add your Claude API key in the AI node credentials.
4. **Set Output Destination**: Configure the webhook/email node with your preferred delivery method.
5. **Set Variables**: Update the workflow settings with your:
   - GitHub repository URL
   - Preferred language (EN/FR)
   - Summary destination (webhook URL or email address)

## Configuration

The workflow uses the following configurable variables:

- `GITHUB_REPO`: The GitHub repository to summarize (e.g., `n8n-io/n8n`)
- `LANGUAGE`: The summary language (`EN` or `FR`)
- `DESTINATION_WEBHOOK`: The webhook URL for delivery (e.g., Slack/Discord)

## Nodes Overview

1. **Cron**: Triggers every Friday at 5 PM
2. **GitHub**: Fetches weekly commits, issues, and pull requests
3. **Function**: Processes and formats the data
4. **Claude AI**: Generates the narrative summary
5. **Webhook/Email**: Delivers the summary

## Screenshot

![Execution Screenshot](execution.png)
*Started by the Claude builder community · March 2026 · MIT License*
