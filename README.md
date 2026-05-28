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

# n8n + Claude Code - Weekly Dev Summary

This workflow automatically generates a weekly narrative summary of GitHub repository activity using the Claude API.

## Setup Instructions

1. **Import the workflow**  
   - In n8n, go to `Settings` → `Import/Export` → `Import` and upload the workflow JSON file.
   
2. **Configure GitHub credentials**
   - Go to `GitHub` node in the workflow
   - Add your GitHub Personal Access Token with `repo` scope
   
3. **Configure Claude API credentials**
   - Create an API key at [console.anthropic.com](https://console.anthropic.com)
   - Add it in the `Claude API` node
   
4. **Configure Email settings (optional)**
   - Go to `Settings` → `Email` and configure your SMTP settings
   - Or disable the email node if you don't want email delivery

5. **Test the workflow**
   - Run the `Manual` node to test execution
   - Check your email or webhook target for the summary

## Configuration Variables

- `githubRepo` - Repository to summarize (format: owner/repo)
- `destinationChannel` - Where to send the summary (email/webhook)
- `language` - Summary language (EN/FR)
*Started by the Claude builder community · March 2026 · MIT License*
