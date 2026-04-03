#!/usr/bin/env bash
#
# Prompt Intercept — /music command
#
# Intercepts /music, toggles playback, and blocks the API call.
# The stub command file exists only for /help discoverability.
#
# Based on: https://github.com/kylesnowschwartz/prompt-intercept-pattern

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

input="$(cat)"
prompt="$(echo "$input" | jq -r '.prompt // .user_prompt // ""')"

# Only handle /music — pass everything else through
case "$prompt" in
/music* | /claude-code-hero:music*) ;;
*)
  echo '{}'
  exit 0
  ;;
esac

# ── Toggle music ─────────────────────────────────────────────
output=$(bash "$SCRIPT_DIR/toggle-music.sh" 2>/dev/null)

if echo "$output" | grep -q "Music: on"; then
  message="The bard strikes up a tune."
else
  message="The bard falls silent."
fi

# ── Block ────────────────────────────────────────────────────
jq -n --arg reason "$message" '{
  decision: "block",
  reason: $reason
}'
