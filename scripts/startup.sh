#!/usr/bin/env bash
# Claude Code Hero - Startup
# Initializes progress file, reconciles state with verify.sh, outputs JSON summary.
# Usage: bash scripts/startup.sh

set -euo pipefail

PROGRESS_FILE="$HOME/.claude/claude-code-hero.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Initialize progress file if missing ---
if [[ ! -f "$PROGRESS_FILE" ]]; then
  mkdir -p "$(dirname "$PROGRESS_FILE")"
  echo '{"current_level": 1, "completed": {}}' >"$PROGRESS_FILE"
fi

# --- Read current state ---
current_level=$(python3 -c "import json; print(json.load(open('$PROGRESS_FILE'))['current_level'])")
completed=$(python3 -c "import json; print(json.dumps(json.load(open('$PROGRESS_FILE')).get('completed', {})))")

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
    has_key=$(python3 -c "import json; d=json.loads('$updated_completed'); print('yes' if '$i' in d else 'no')")
    if [[ "$has_key" == "no" ]]; then
      updated_completed=$(python3 -c "
import json, datetime
d = json.loads('$updated_completed')
d['$i'] = datetime.datetime.now(datetime.timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
print(json.dumps(d))
")
    fi
  done

  # Write reconciled progress
  python3 -c "
import json
progress = {'current_level': $new_level, 'completed': json.loads('$updated_completed')}
with open('$PROGRESS_FILE', 'w') as f:
    json.dump(progress, f)
"
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
cat <<EOF
{
  "current_level": $current_level,
  "completed": $completed,
  "highest_passing": $highest_passing,
  "status": "$status"
}
EOF
