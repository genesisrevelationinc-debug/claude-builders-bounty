# Security Hook for Claude Code

This hook blocks dangerous bash commands before they are executed.

## Installation

1. Make the hook executable: `chmod +x ~/.claude/hooks/pre-tool-use`
2. That's it! The hook is now active and will block dangerous commands automatically.

All blocked commands are logged to `~/.claude/hooks/blocked.log` with timestamps and project paths.