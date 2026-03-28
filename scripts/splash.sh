#!/usr/bin/env bash
# Splash screen hook -- fires on SessionStart to inject the game banner.
# The heroguide agent sees this as additionalContext and displays it
# before the first quest prompt.
#
# The ASCII art is hardcoded in banner.txt so it renders identically
# regardless of whether figlet is installed on the player's machine.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BANNER=$(cat "$SCRIPT_DIR/banner.txt")

INSTRUCTION="Display this ASCII art banner at the very start of your response, before any narrative or quest content. Output it inside a code block so it renders with monospace alignment:

\`\`\`
${BANNER}
\`\`\`

Then proceed with your normal startup sequence."

# Escape for JSON using bash parameter substitution (same pattern as superpowers)
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

printf '{\n  "hookSpecificOutput": {\n    "hookEventName": "SessionStart",\n    "additionalContext": "%s"\n  }\n}\n' "$escaped"

exit 0
