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

# Destructive Command Blocker Hook

This Claude Code hook blocks destructive bash commands before they are executed.

## Installation

1. Place the hook file in `~/.claude/hooks/pre-tool-use`
2. Make the hook executable: `chmod +x ~/.claude/hooks/pre-tool-use`

## Features

- Blocks dangerous commands like `rm -rf`, `DROP TABLE`, `git push --force`, `TRUNCATE`, and `DELETE FROM` without WHERE clause
- Logs all blocked commands to `~/.claude/hooks/blocked.log` with timestamp and project path
- Prevents accidental data loss in Claude Code workflows

## Blocked Commands

The hook blocks these specific patterns:

- `rm -rf` and `rm -rf *`
- `DROP TABLE`
- `TRUNCATE TABLE`
- `DELETE FROM table` (without a WHERE clause)
- `git push --force`

## Log Format

Each blocked command is logged in the following format:


*Started by the Claude builder community · March 2026 · MIT License*
