<!-- BEGIN_README -->

# Claude Builders Bounty 🤖
# claude-review — PR Reviewer Agent

A Claude Code sub-agent that takes a GitHub pull request as input, analyzes the diff, and posts a structured Markdown review comment.

## Features

- Fetches PR diff via the GitHub API (no local clone required)
- Produces a structured review with:
  - **Summary** (2–3 sentences)
  - **Identified risks** (bulleted list)
  - **Improvement suggestions** (bulleted list)
  - **Confidence score** (Low / Medium / High)
- Works as a CLI tool or inside a GitHub Action

## Setup

### 1. Prerequisites

- [Claude Code](https://claude.ai/code) installed and configured
- A [GitHub personal access token](https://github.com/settings/tokens) with `repo` scope (for private repos) or `public_repo` (for public repos)

### 2. Install the agent



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
---

*Started by the Claude builder community · March 2026 · MIT License*

<!-- END_README -->

## Community

- 🐦 X: [@ClaudeBounty](https://x.com/ClaudeBounty)
- 📧 Contact: claudebounty@gmail.com

---

*Started by the Claude builder community · March 2026 · MIT License*
