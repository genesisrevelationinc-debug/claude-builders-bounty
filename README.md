# Claude Builders Bounty 🤖

## Automated Weekly Dev Summary Workflow

This repository contains an n8n workflow that automatically generates weekly development summaries using Claude API.

### Setup Instructions

1. **Import the Workflow**: Import the JSON workflow file into your n8n instance
   - Open n8n and go to the Workflows page
   - Click "Import" and select the workflow JSON file
   - Configure the GitHub credentials node credentials

2. **Configure GitHub Token**: 
   - Create a GitHub personal access token with repo permissions
   - In the workflow, configure the GitHub credential with your token
   - Set the repository owner and name in the GitHub node

3. **Configure Claude API Key**: 
   - Add your Anthropic API key to the Claude node
   - Set the model to claude-sonnet-4-20250514

4. **Set Delivery Method**:
   - For email: Configure the "Send Email" node with your SMTP settings
   - For Discord: Configure the "Discord" node with your webhook URL
   - For Slack: Configure the "Slack" node with your webhook URL

5. **Set Configuration Variables**:
   - Set the cron expression for weekly execution (e.g., "0 0 17 * * 5" for Friday 5PM)
   - Set the target repository owner and name
   - Choose your summary language (EN/FR)
   - Configure the workflow active repository

### Workflow Nodes:

- **Cron**: Triggers the workflow on a schedule
- **GitHub**: Fetches repository activity (commits, issues, PRs)
- **Claude API**: Generates narrative summary from GitHub activity
- **Email/Discord/Slack**: Delivers the summary

### Files

[File structure]

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

*Started by the Claude builder community · March 2026 · MIT License*
