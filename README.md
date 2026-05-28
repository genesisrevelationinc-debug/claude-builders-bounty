# n8n-claude-weekly-summary:README

## Setup Instructions

1. Import this workflow into your n8n instance
2. Set up a "Claude API" credentials with your API key
3. Configure the "Schedule" node to point to your webhook/HTTP endpoint
4. Configure the "Cron" node to run on Fridays at 5pm
5. Configure the "Email" or "HTTP" nodes for delivery

## Usage

1. Create a new `.env` file and place your Claude API key in it
2. Set `N8N_CONFIG_` as the prefix for the env variables
3. Set `GITHUB_REPO` to the target repository
4. Set `CLAUDE_MODEL` to `claude-sonnet-4-20250514` or `claude-opus-20240514`
5. Set `WEBHOOK_URL` or `EMAIL_RECIPIENT` based on your delivery method

## Workflow

This workflow will:
1. Trigger every Friday at 5pm
2. Collect data from GitHub API
3. Generate a narrative summary using Claude API
4. Send the summary via email or messaging

## Configurable Variables

- GITHUB_REPOSITORY: The GitHub repository to track (e.g. `organization/repository`)
- DESTINATION_CHANNEL: The channel to send the summary to (e.g. `#general`)
- LANGUAGE: The language to use for the summary (EN/FR)

## How to run

1. Create a new `.env` file:
   

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
