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
| [#1](../../issues/1) | SKILL: Generate a CHANGELOG from git history | $50 | 🟢 Open |
| [#2](../../issues/2) | TEMPLATE: CLAUDE.md for a Next.js + SQLite project | $75 | 🟢 Open |
| [#3](../../issues/3) | HOOK: Block destructive bash commands in Claude Code | $100 | 🟢 Open |
| [#5](../../issues/5) | WORKFLOW: n8n + Claude API — automated weekly dev summary | $200 | 🟢 Open |

## Workflow Solution

### Files
1. `claude_weekly_dev_summary.json` - The main n8n workflow file
2. `README.md` - This file

### Setup Instructions

1. Import the workflow:
   - In n8n, go to menu > Import > select the JSON file
   - Configure the GitHub node with your repo details
   - Set up the Claude API credentials in n8n
   - Adjust the cron expression if needed (currently set to Friday 5pm)
   - Set up the destination (email or webhook URL) for the summary

2. Configuration variables:
   - GitHub repository URL
   - Claude API key
   - Notification destination (email or webhook)
   - Language preference (EN/FR)

3. Execution:
   - The workflow runs every Friday at 5pm
   - It fetches GitHub activity for the past week
   - Generates a narrative summary using Claude API
   - Sends the summary to your chosen destination

### Prerequisites

- n8n instance running
- GitHub personal access token with repo permissions
- Claude API key (claude-sonnet-4-20250514 model)
- Internet connection

### How to Test

1. Set up the n8n workflow according to the imported configuration
2. Run the workflow manually to test
3. Check that the workflow produces a narrative summary
4. Confirm the summary is sent to your chosen destination
5. Verify the summary includes GitHub activity for the past week

### Troubleshooting

- Ensure all API keys are correctly set in the environment variables
- Check that the cron job is correctly configured
- Verify the GitHub node is properly configured with the repository URL

### Notes

- This workflow uses the claude-sonnet-4-20250514 model
- The summary is generated in the configured language (EN/FR)
- The workflow handles errors gracefully and logs them

### Claiming the Bounty

To claim the $200 bounty:

1. Comment `/opire try` in the GitHub issue
2. Submit a PR with the workflow file and updated README
3. Payment is released automatically on merge ✅

### Resources

- n8n docs: https://docs.n8n.io
- Claude API docs: https://docs.anthropic.com

### Contact

For questions or support, please open an issue in the repository.
## Community

- 🐦 X: [@ClaudeBounty](https://x.com/ClaudeBounty)
- 📧 Contact: claudebounty@gmail.com

---

*Started by the Claude builder community · March 2026 · MIT License*
