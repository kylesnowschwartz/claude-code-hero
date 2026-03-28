#!/usr/bin/env bash
# PreToolUse hook for the Skill tool -- injects a level banner when
# the dungeon-master agent loads a level skill.
#
# Reads tool_input.skill from stdin JSON, checks if it matches
# "level-N-*", and if a banner exists for that level, injects it
# via additionalContext.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

INPUT=$(cat)
SKILL_NAME=$(echo "$INPUT" | jq -r '.tool_input.skill // ""')

# Extract level number from skill name
# Fully qualified: "claude-code-hero:level-2-the-tome"
# Short form: "level-2-the-tome"
if [[ "$SKILL_NAME" =~ level-([0-9]+)- ]]; then
  LEVEL="${BASH_REMATCH[1]}"
else
  # Not a level skill, pass through
  exit 0
fi

BANNER_FILE="$SCRIPT_DIR/banners/level-${LEVEL}.txt"

if [[ ! -f "$BANNER_FILE" ]]; then
  # No banner for this level yet, pass through
  exit 0
fi

BANNER=$(cat "$BANNER_FILE")

INSTRUCTION="Display this ASCII art level banner at the start of your response, before presenting the quest. Output it inside a code block so it renders with monospace alignment:

\`\`\`
${BANNER}
\`\`\`

Then proceed with presenting the quest."

# Escape for JSON using bash parameter substitution
escape_for_json() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/\\r}"
  s="${s//$'\t'/\\t}"
  printf '%s' "$s"
}

escaped=$(escape_for_json "$INSTRUCTION")

printf '{\n  "hookSpecificOutput": {\n    "hookEventName": "PreToolUse",\n    "permissionDecision": "allow",\n    "additionalContext": "%s"\n  }\n}\n' "$escaped"

exit 0
