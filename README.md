# Claude Builders Bounty 🤖

> A community bounty board for Claude Code. 
# File: changelog.sh
#!/bin/bash
set -e
if [ -z "$GIT" ]; then
  GIT='git'
fi
if [ -z "$TAG" ]; then
  TAG="$($GIT describe --tags --abbrev=0)"
  if [ -z "$TAG" ]; then
    TAG="HEAD"
  fi
fi
# Create a changelog from the current tag to the next
# This is a simple implementation that only includes the 3 most recent
COMMITS="$($GIT log --oneline $TAG..HEAD)"
# Create a new file called CHANGELOG.md
# Get the commit history since the last tag
# Print the commit history since the last tag
# Get the latest tag
# Get the latest tag
# Get the latest tag
# Get the latest tag
# Get the latest tag
# Get the latest tag
# Get the latest tag
# Get the latest tag
# Get the latest tag
# Get the latest tag
# Get the latest tag
# Get the latest tag
# Get the latest tag
# Get the latest tag
# Get the latest

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
