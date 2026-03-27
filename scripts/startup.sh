#!/usr/bin/env bash
# Claude Code Hero - Startup
# Initializes progress file, reconciles state with verify.sh, outputs JSON summary.
# Usage: bash scripts/startup.sh

set -euo pipefail

# --- Prerequisites ---
if ! command -v jq &>/dev/null; then
  echo "Error: jq is required but not installed. Install with: brew install jq" >&2
  exit 1
fi

PROGRESS_FILE="$HOME/.claude/claude-code-hero.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Initialize progress file if missing ---
if [[ ! -f "$PROGRESS_FILE" ]]; then
  mkdir -p "$(dirname "$PROGRESS_FILE")"
  echo '{"current_level": 1, "completed": {}}' >"$PROGRESS_FILE"
fi

# --- Read current state ---
current_level=$(jq '.current_level' "$PROGRESS_FILE")
completed=$(jq -c '.completed // {}' "$PROGRESS_FILE")

# --- Reconcile: check if artifacts exist beyond current_level ---
highest_passing=0
for i in $(seq 1 9); do
  if bash "$SCRIPT_DIR/verify.sh" "$i" >/dev/null 2>&1; then
    highest_passing=$i
  else
    break
  fi
done

# Advance current_level if artifacts exist ahead of tracked progress
if [[ "$highest_passing" -ge "$current_level" ]]; then
  new_level=$((highest_passing + 1))
  if [[ "$new_level" -gt 9 ]]; then
    new_level=10
  fi

  # Backfill completed timestamps for any levels that pass but aren't recorded
  updated_completed="$completed"
  for i in $(seq 1 "$highest_passing"); do
    has_key=$(echo "$updated_completed" | jq --arg k "$i" 'has($k)')
    if [[ "$has_key" == "false" ]]; then
      ts=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
      updated_completed=$(echo "$updated_completed" | jq --arg k "$i" --arg v "$ts" '. + {($k): $v}')
    fi
  done

  # Write reconciled progress
  jq -n --argjson level "$new_level" --argjson completed "$updated_completed" \
    '{"current_level": $level, "completed": $completed}' >"$PROGRESS_FILE"

  current_level=$new_level
  completed=$updated_completed
fi

# --- Determine status ---
if [[ "$current_level" -ge 10 ]]; then
  status="complete"
elif [[ "$current_level" -eq 1 ]] && [[ "$completed" == "{}" ]]; then
  status="new"
else
  status="in_progress"
fi

# --- Output structured summary ---
jq -n \
  --argjson current_level "$current_level" \
  --argjson completed "$completed" \
  --argjson highest_passing "$highest_passing" \
  --arg status "$status" \
  '{current_level: $current_level, completed: $completed, highest_passing: $highest_passing, status: $status}'
