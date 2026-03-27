---
description: Verify your current Claude Code Hero quest level
argument-hint: [level-number]
allowed-tools: Bash, Read
---

Verify quest completion for Claude Code Hero.

The verification script is at: !`echo ${CLAUDE_PLUGIN_ROOT}/scripts/verify.sh`

If the user provided a level number ($ARGUMENTS), verify that specific level. Otherwise, read `~/.claude/claude-code-hero.json` to find `current_level` and verify that.

Run: `bash <script-path> <level-number>`

Report the result:
- **PASS**: State what was verified and that the level is complete. Keep it brief.
- **FAIL**: Show the failure message from the script so the user knows what to fix.
