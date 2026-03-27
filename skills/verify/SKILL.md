---
name: verify
description: "Verify your current Claude Code Hero quest level. Use when the learner types /verify, asks to check their work, or wants to see quest progress."
argument-hint: "[level-number]"
allowed-tools: Bash("jq '.current_level' ~/.claude/claude-code-hero.json"), Read
---

Verify quest completion for Claude Code Hero. The CLI is the source of truth -- do not perform semantic evaluation.

$ARGUMENTS

## How to run

<current_level>
 !`jq '.current_level' ~/.claude/claude-code-hero.json`
</current_level>

Always pass a level number to the CLI.

1. **`/verify 5`** -- user gave a level number. Run `ruby scripts/cli.rb verify 5`. Report PASS or FAIL. Done.
2. **`/verify`** -- no argument. Run `ruby scripts/cli.rb verify <current_level>`. Report PASS or FAIL. Done.

## Reporting

- **PASS**: State what was verified and that the level is complete. Brief.
- **FAIL**: Show the CLI's failure message so the learner knows what to fix.
