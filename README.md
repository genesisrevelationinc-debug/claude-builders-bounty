# Claude Builders Bounty 🤖

> A community bounty board for Claude Code builders.

Building with Claude Code? Have tasks to delegate?
Want to get paid for contributing to AI projects?
You're in the right place.

## Automated Weekly Dev Summary Workflow

This workflow automates the generation of weekly development summaries using n8n and Claude API.

### Features
- Runs weekly to summarize GitHub repository activity
- Generates narrative summaries of commits, issues and pull requests
- Sends output to configured notification channels
- Supports both English and French language output

### Setup Instructions

1. **Import the Workflow**: Import the `weekly-dev-summary.json` file into your n8n instance.
2. **Configure GitHub Token**: Add your GitHub personal access token for API access.
2. **Set Up Environment Variables**: Configure the following variables:
   - `GITHUB_REPOSITORY`: Target GitHub repository
   - `NOTIFY_SLACK`: Optional Slack webhook URL
   - `NOTIFY_EMAIL`: Optional email configuration
   - `LANGUAGE`: 'EN' or 'FR' for output language
3. **Configure the Schedule**: Set your workflow to run on a weekly schedule (e.g., every Friday at 5pm).
4. **Test the Workflow**: Run a test execution to verify data and notification flows.

### Configuration
To customize the workflow for your specific needs, update the corresponding fields in the n8n environment settings.

### Example Output

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
