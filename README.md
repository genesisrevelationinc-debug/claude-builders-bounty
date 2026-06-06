## Automated Weekly Development Summary Workflow

This repository contains an n8n workflow that automatically generates a weekly narrative summary of GitHub repository activity using Claude AI.

### Files

- `weekly-dev-summary.json` - The exportable n8n workflow
- This README file

### Setup Instructions

1. Import the n8n workflow by going to your n8n instance and selecting "Import Workflow" and uploading the JSON file
2. Configure the GitHub credentials node with a personal access token that has appropriate repo permissions
3. Set the GitHub Repository Name variable to your target repository
4. Configure the destination in the "Destination Channel" variable (email address or webhook URL)
5. Set the workflow to be activated on a weekly cron schedule (e.g., every Friday at 5pm)

### Configuration Variables

- `GitHub Repository Name` - The target repository to summarize (e.g., "claude-builders-bounty/claude-builders-bounty")
- `Destination` - Where to send the summary (email address or webhook URL)
- `Language` - Summary language (EN or FR)

### Workflow Nodes

1. **Cron** - Triggers the workflow on a weekly schedule
2. **GitHub** - Fetches repository activity (commits, issues, PRs) from the GitHub API
3. **Function** - Processes and formats the data for Claude AI
4. **Claude AI** - Generates the narrative summary
5. **Deliver Summary** - Sends the summary to the configured destination

### Prerequisites

To use this workflow, you'll need:

- An n8n instance (cloud or self-hosted)
- A GitHub personal access token with repo permissions
- An Anthropic API key for Claude access

### How it works

Every week, this workflow:

1. **Triggers** - Runs automatically every Friday at 5pm
2. **Fetches Data** - Gets the week's commits, closed issues, and merged PRs from GitHub
3. **Summarizes** - Sends the activity data to Claude AI to generate a narrative summary
4. **Delivers** - Sends the summary via email or webhook

### Example Output

**Subject: Your Weekly Development Summary - claude-builders-bounty/claude-builders-bounty**

## Development Summary for claude-builders-bounty/claude-builders-bounty
This week's highlights:

- 12 new commits
- 3 issues closed
- 2 pull requests merged

The team integrated the new authentication system...

### Configuration
- Install the workflow in n8n
- Set your GitHub token in the credentials
- Configure the variables for your repository
- Set the destination for the summary (email or webhook)

### Support

For support, see the [n8n documentation](https://docs.n8n.io) or contact the Claude Builders community.

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

*Started by the Claude builder community · March 2026 · MIT License*
