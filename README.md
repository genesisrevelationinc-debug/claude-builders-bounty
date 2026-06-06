<a name="bounty-4"></a>
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
| [#3](../../issues/3) | HOOK: Block destructive bash commands in Claude Code | $100 | 🟢 Open |
| [#4](../../issues/4) | AGENT: PR reviewer with structured Markdown output | $150 | 🟢 Open |
| [#5](../../issues/5) | WORKFLOW: n8n + Claude API — automated weekly dev summary | $200 | 🟢 Open |

## Sample Output for Bounty #4

### Summary of Changes
This PR introduces a new Claude Code agent that reviews GitHub PRs and provides structured feedback. The agent can be used via CLI or as a GitHub Action.

### Identified Risks
- The CLI version may require GitHub CLI to be installed
- Rate limits on the Claude Code API if processing many PRs

### Improvement Suggestions
- Add support for commenting directly on the PR
- Include code quality metrics in the review
- Add configuration file support for customizing review criteria

### Confidence: High

## How to Use

To claim this bounty, we have implemented a solution that includes both a CLI tool and a GitHub Action. See the implementation in `bounty-4/claude-pr-reviewer/` directory.

## Features

- Works via CLI: `claude-review --pr <PR_URL>`
- Works via GitHub Action
- Provides structured Markdown output with summary, risks, and suggestions
- Includes a confidence score
- Tested on multiple real PRs

## Setup Instructions

1. Install the package: `npm install -g claude-pr-reviewer`
2. Set your `GITHUB_TOKEN` and `CLAUDE_API_KEY` environment variables
3. Run: `claude-review --pr <PR_URL>`

## GitHub Action Usage


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
