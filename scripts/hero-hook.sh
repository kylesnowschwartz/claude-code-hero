#!/usr/bin/env bash
# Hero Hook -- fires when /hero-spell is cast
# This script is called by a UserPromptSubmit hook in ~/.claude/settings.json.
#
# How it works:
# 1. Claude Code sends JSON to stdin with a "prompt" field
# 2. We check if the prompt starts with "/hero-spell"
# 3. If it matches, we run YOUR command and tell the user what happened
# 4. If it doesn't match, we exit silently -- other prompts pass through untouched

set -euo pipefail

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""')

# Only react to /hero-spell -- let everything else pass through
if [[ "$PROMPT" != "/hero-spell"* ]]; then
  exit 0
fi

# Strip the command name to get the target
TARGET="${PROMPT#/hero-spell}"
TARGET="${TARGET# }" # trim leading space
TARGET="${TARGET:-the darkness}"

# ============================================================
# YOUR COMMAND: Replace the next line with your notification.
#
# Examples:
#   echo "hero: Magic Missile fired at $TARGET ($(date))" >> /tmp/hero-hook-log.txt
#   osascript -e "display notification \"Magic Missile fired at $TARGET\" with title \"Claude Code Hero\""
#
echo "hero: REPLACE_ME - edit hero-hook.sh with your command" >>/tmp/hero-hook-log.txt
# ============================================================

# Tell Claude Code what happened (displayed to the user, no API call spent)
echo "{\"decision\":\"block\",\"reason\":\"Magic Missile strikes $TARGET!\"}"
