#!/usr/bin/env bash
# Toggle music: flip the preference, then start or stop playback.
# Single script so the /music command needs one Bash call.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Flip the preference and capture new state
OUTPUT=$(ruby "$SCRIPT_DIR/cli.rb" music toggle)
NEW_STATE=$(echo "$OUTPUT" | jq -r '.music')

# Kill current playback
pkill -f 'afplay.*assets/audio' 2>/dev/null || true
pkill -f 'play-music.sh' 2>/dev/null || true

if [[ "$NEW_STATE" == "true" ]]; then
  sleep 0.3
  bash "$SCRIPT_DIR/play-music.sh"
  echo "Music: on"
else
  echo "Music: off"
fi
