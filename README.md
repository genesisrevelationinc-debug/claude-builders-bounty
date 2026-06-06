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

# n8n + Claude Weekly Dev Summary

This workflow automatically generates a weekly narrative summary of GitHub repository activity using Claude API.

## Setup Instructions

1. **Import Workflow**: In n8n, go to Workflows > Import and paste the JSON file.

2. **Configure Credentials**:
   - Add your GitHub Personal Access Token in the GitHub node
   - Add your Claude API key in the Claude node
   - Configure email credentials in the Email node (or use Discord/Slack)

3. **Set Repository**: Update the GitHub node to point to your target repository.

4. **Set Schedule**: The workflow is preconfigured to run weekly on Fridays at 5pm.

5. **Set Delivery**: Update the final node to your preferred delivery method (email, Discord, or Slack).

## Configuration Variables

- **GitHub Repository**: Set in the GitHub node parameters
- **Delivery Method**: Choose email, Discord, or Slack in the last node
- **Language**: The summary will be generated in English by default (FR option available in code)

## Screenshot

![Successful execution screenshot](screenshot.png)
*Started by the Claude builder community · March 2026 · MIT License*
