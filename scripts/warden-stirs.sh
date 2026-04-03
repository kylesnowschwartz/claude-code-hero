#!/usr/bin/env bash
# PreToolUse hook for Write(.claude/hero-journal.md) -- blocks the first
# write to the hero journal with in-world Warden framing, then stands down.
#
# Uses a session-scoped lock file (/tmp/hero-warden-<pid>) to ensure the
# block only happens once. First invocation: deny + lock. All subsequent
# invocations: see the lock, exit silently, tool proceeds.
#
# Level 4 (The Warden's Keys) teaches permissions. Before that, permission
# gates are unfamiliar. This hook introduces the concept in-character.
#
# After Level 4, exits silently. If no progress file exists (not playing),
# also exits silently.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROGRESS_FILE="$PROJECT_ROOT/.claude/claude-code-hero.json"

# Not playing -- no progress file
if [[ ! -f "$PROGRESS_FILE" ]]; then
  exit 0
fi

CURRENT_LEVEL=$(jq -r '.current_level // 0' "$PROGRESS_FILE" 2>/dev/null || echo "0")

# Level 4+ knows about permissions
if [[ "$CURRENT_LEVEL" -ge 4 ]]; then
  exit 0
fi

# Session-scoped lock: block once, then stand down.
# Use session_id from stdin JSON if available, fall back to PID-based lock.
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // ""' 2>/dev/null || true)

if [[ -n "$SESSION_ID" ]]; then
  LOCK_FILE="/tmp/hero-warden-${SESSION_ID}"
else
  LOCK_FILE="/tmp/hero-warden-$$"
fi

# Already blocked once this session -- stand down
if [[ -f "$LOCK_FILE" ]]; then
  exit 0
fi

# First time: create lock and block
touch "$LOCK_FILE"

# Escape for JSON
escape_for_json() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/\\r}"
  s="${s//$'\t'/\\t}"
  printf '%s' "$s"
}

REASON="The Warden blocks the passage. This is the dungeon's permission guardian -- the player will learn to command it in Level 4 (The Warden's Keys). Acknowledge the Warden briefly in-character (one or two lines), then call the Write tool again with the same file path and content. The Warden only blocks once -- the retry will succeed."

escaped=$(escape_for_json "$REASON")

printf '{\n  "hookSpecificOutput": {\n    "hookEventName": "PreToolUse",\n    "permissionDecision": "deny",\n    "permissionDecisionReason": "%s"\n  }\n}\n' "$escaped"
