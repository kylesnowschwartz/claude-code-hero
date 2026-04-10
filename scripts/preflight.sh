#!/usr/bin/env bash
# Preflight check -- validates ruby and jq are available and compatible.
# Runs as a SessionStart hook. Caches results in .claude/claude-code-hero.json
# under a "preflight" key so subsequent sessions exit immediately when
# versions haven't changed.
#
# Dependencies checked:
#   ruby >= 3.0  -- quest engine (endless methods, filter_map)
#   jq           -- hook scripts parse JSON via jq
#
# On failure, returns additionalContext telling the agent to warn the player.
# On success, caches versions and hands off to splash.sh for the game banner.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROGRESS_FILE="$PROJECT_ROOT/.claude/claude-code-hero.json"
MIN_RUBY_MAJOR=3

# --- helpers ---

escape_for_json() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/\\r}"
  s="${s//$'\t'/\\t}"
  printf '%s' "$s"
}

warn_user() {
  local escaped
  escaped=$(escape_for_json "$1")
  printf '{\n  "hookSpecificOutput": {\n    "hookEventName": "SessionStart",\n    "additionalContext": "%s"\n  }\n}\n' "$escaped"
}

# --- debug: force failure for testing ---
# Usage: HERO_PREFLIGHT_FAIL=1 claude --plugin-dir . --agent dungeon-master

if [[ "${HERO_PREFLIGHT_FAIL:-}" == "1" ]]; then
  CURRENT_RUBY=""
  CURRENT_JQ=""
else
  # --- detect current versions ---

  CURRENT_RUBY=""
  if command -v ruby >/dev/null 2>&1; then
    CURRENT_RUBY=$(ruby -e 'puts RUBY_VERSION' 2>/dev/null || true)
  fi

  CURRENT_JQ=""
  if command -v jq >/dev/null 2>&1; then
    CURRENT_JQ=$(jq --version 2>/dev/null | sed 's/jq-//' || true)
  fi
fi

# --- fast path: compare against cache ---

if [[ -n "$CURRENT_JQ" && -n "$CURRENT_RUBY" && -f "$PROGRESS_FILE" ]]; then
  CACHED_RUBY=$(jq -r '.preflight.ruby // ""' "$PROGRESS_FILE" 2>/dev/null || true)
  CACHED_JQ=$(jq -r '.preflight.jq // ""' "$PROGRESS_FILE" 2>/dev/null || true)

  if [[ "$CACHED_RUBY" == "$CURRENT_RUBY" && "$CACHED_JQ" == "$CURRENT_JQ" ]]; then
    exec bash "$SCRIPT_DIR/splash.sh"
  fi
fi

# --- validate ---

PROBLEMS=()

if [[ -z "$CURRENT_RUBY" ]]; then
  PROBLEMS+=("Ruby is not installed. The quest engine requires Ruby >= ${MIN_RUBY_MAJOR}.0.")
else
  RUBY_MAJOR="${CURRENT_RUBY%%.*}"
  if [[ "$RUBY_MAJOR" -lt "$MIN_RUBY_MAJOR" ]]; then
    PROBLEMS+=("Ruby ${CURRENT_RUBY} is too old. The quest engine requires Ruby >= ${MIN_RUBY_MAJOR}.0.")
  fi
fi

if [[ -z "$CURRENT_JQ" ]]; then
  PROBLEMS+=("jq is not installed. Hook scripts need jq for JSON parsing.")
fi

if [[ ${#PROBLEMS[@]} -gt 0 ]]; then
  MSG="PREFLIGHT FAILED -- Claude Code Hero needs these fixed before quests will work:\n"
  for p in "${PROBLEMS[@]}"; do
    MSG+="\n- ${p}"
  done
  MSG+="\n\nInstall options:"
  MSG+="\n- macOS: brew install ruby jq"
  MSG+="\n- Linux: apt install ruby jq"
  MSG+="\n- Or run: bash scripts/install.sh"
  MSG+="\n\nTell the player what is missing and how to fix it. Do not proceed with quests until dependencies are resolved."

  warn_user "$MSG"
  exit 0
fi

# --- all good: update cache ---

if [[ -f "$PROGRESS_FILE" ]]; then
  tmp=$(jq --arg ruby "$CURRENT_RUBY" --arg jq_ver "$CURRENT_JQ" \
    '.preflight = {ruby: $ruby, jq: $jq_ver}' "$PROGRESS_FILE")
  printf '%s\n' "$tmp" >"$PROGRESS_FILE"
else
  mkdir -p "$(dirname "$PROGRESS_FILE")"
  jq -n --arg ruby "$CURRENT_RUBY" --arg jq_ver "$CURRENT_JQ" \
    '{preflight: {ruby: $ruby, jq: $jq_ver}}' >"$PROGRESS_FILE"
fi

# --- deps good: show the splash ---

exec bash "$SCRIPT_DIR/splash.sh"
