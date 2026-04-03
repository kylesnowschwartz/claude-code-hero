#!/usr/bin/env bash
# Play the level-appropriate background track in a loop.
# Called by splash.sh on startup and by the /music command for toggle-on.
#
# Track assignment:
#   Levels 0-2: dungeon-crawl.mp3 (chill exploration)
#   Levels 3+:  perilous-dungeon.mp3 (building artifacts)
#
# Loops until killed. The SessionEnd hook and /music toggle handle cleanup.
# This script backgrounds itself and exits immediately.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AUDIO_DIR="$SCRIPT_DIR/../assets/audio"
PROGRESS_FILE="$SCRIPT_DIR/../.claude/claude-code-hero.json"

# Determine current level
CURRENT_LEVEL=0
if [[ -f "$PROGRESS_FILE" ]] && command -v jq >/dev/null 2>&1; then
  CURRENT_LEVEL=$(jq -r '.current_level // 0' "$PROGRESS_FILE" 2>/dev/null || echo "0")
fi

# Pick track based on level
if [[ "$CURRENT_LEVEL" -lt 3 ]]; then
  TRACK="$AUDIO_DIR/dungeon-crawl.mp3"
else
  TRACK="$AUDIO_DIR/perilous-dungeon.mp3"
fi

if [[ ! -f "$TRACK" ]]; then
  exit 0
fi

# Find a player command
PLAYER=""
if command -v afplay >/dev/null 2>&1; then
  PLAYER="afplay"
elif command -v aplay >/dev/null 2>&1; then
  PLAYER="aplay"
else
  exit 0
fi

# Loop playback in background subshell
(
  while true; do
    $PLAYER "$TRACK" 2>/dev/null
  done
) &>/dev/null &

exit 0
