#!/usr/bin/env bash
# Claude Code Hero - True Restart
# Removes all hero-specific artifacts so verification fails, then resets progress.
# Surgical: only removes hero-* files and hero-specific entries from shared configs.
#
# Usage: bash scripts/restart.sh [--dry-run]

set -euo pipefail

# --- Prerequisites ---
if ! command -v jq &>/dev/null; then
  echo "Error: jq is required but not installed. Install with: brew install jq" >&2
  exit 1
fi

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

CLAUDE_DIR="$HOME/.claude"
PROGRESS_FILE="$CLAUDE_DIR/claude-code-hero.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

removed=0
skipped=0

action() {
  if $DRY_RUN; then
    echo "  [dry-run] $1"
  else
    echo "  $1"
  fi
}

remove_file() {
  local file="$1"
  local label="$2"
  if [[ -f "$file" ]]; then
    action "Remove $label ($file)"
    $DRY_RUN || rm "$file"
    removed=$((removed + 1))
  else
    skipped=$((skipped + 1))
  fi
}

remove_dir_contents() {
  # Removes known files from a directory, then rmdir (which fails safely if non-empty).
  # Never uses rm -rf. If unexpected files exist, the directory stays and the user can inspect.
  local dir="$1"
  local label="$2"
  shift 2
  local files=("$@") # specific filenames to remove within the dir

  if [[ ! -d "$dir" ]]; then
    skipped=$((skipped + 1))
    return
  fi

  action "Clean $label ($dir/)"
  if ! $DRY_RUN; then
    for f in "${files[@]}"; do
      [[ -f "$dir/$f" ]] && rm "$dir/$f"
    done
    # rmdir only succeeds on empty directories -- safe by design
    rmdir "$dir" 2>/dev/null || true
  fi
  removed=$((removed + 1))
}

echo "Claude Code Hero -- True Restart"
echo "================================="
echo ""

# --- Level 1: hero-map.md ---
echo "Level 1 - The Map Room:"
remove_file "$CLAUDE_DIR/hero-map.md" "hero-map.md"

# --- Level 2: Hero's Decree section in CLAUDE.md ---
echo "Level 2 - The Tome of First Instructions:"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
if [[ -f "$CLAUDE_MD" ]] && grep -q "## Hero's Decree" "$CLAUDE_MD"; then
  action "Remove '## Hero's Decree' section from CLAUDE.md"
  if ! $DRY_RUN; then
    # Remove from "## Hero's Decree" to the next "## " heading or end of file.
    # Uses sed to delete the range, then trims trailing blank lines.
    sed -i '' '/^## Hero.s Decree$/,/^## /{/^## Hero.s Decree$/d;/^## /!d;}' "$CLAUDE_MD"
    # Clean up any trailing blank lines left behind
    sed -i '' -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$CLAUDE_MD"
  fi
  removed=$((removed + 1))
else
  skipped=$((skipped + 1))
fi

# --- Level 3: hero-spell command ---
echo "Level 3 - The Goblin Lair of Commands:"
remove_file "$CLAUDE_DIR/commands/hero-spell.md" "hero-spell.md"

# --- Level 4: hero permission rules in settings.json ---
echo "Level 4 - The Warden's Keys:"
SETTINGS="$CLAUDE_DIR/settings.json"
if [[ -f "$SETTINGS" ]]; then
  hero_rules='["Bash(git:*)", "Bash(git push:*)", "Bash(git push --force:*)"]'
  has_hero_perms=$(jq --argjson rules "$hero_rules" '
    .permissions // {} |
    [.allow // [], .ask // [], .deny // []] | add |
    any(. as $r | $rules | any(. == $r))
  ' "$SETTINGS")

  if [[ "$has_hero_perms" == "true" ]]; then
    action "Remove hero permission rules from settings.json"
    if ! $DRY_RUN; then
      jq '
        .permissions.allow |= (if . then [.[] | select(. != "Bash(git:*)")] else . end) |
        .permissions.ask |= (if . then [.[] | select(. != "Bash(git push:*)")] else . end) |
        .permissions.deny |= (if . then [.[] | select(. != "Bash(git push --force:*)")] else . end) |
        # Clean up empty arrays
        if .permissions.allow == [] then del(.permissions.allow) else . end |
        if .permissions.ask == [] then del(.permissions.ask) else . end |
        if .permissions.deny == [] then del(.permissions.deny) else . end |
        # Clean up empty permissions object
        if .permissions == {} then del(.permissions) else . end
      ' "$SETTINGS" >"$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
    fi
    removed=$((removed + 1))
  else
    skipped=$((skipped + 1))
  fi
else
  skipped=$((skipped + 1))
fi

# --- Level 5: hero-voice output style ---
echo "Level 5 - The Shapeshifter's Mask:"
remove_file "$CLAUDE_DIR/output-styles/hero-voice.md" "hero-voice.md"

# --- Level 6: hero hook in settings.json + reset hero-hook.sh ---
echo "Level 6 - The Tripwire Cavern:"
if [[ -f "$SETTINGS" ]]; then
  has_hero_hook=$(jq '
    .hooks.UserPromptSubmit // [] |
    any(tostring | test("hero-hook"))
  ' "$SETTINGS")

  if [[ "$has_hero_hook" == "true" ]]; then
    action "Remove hero-hook entry from settings.json hooks"
    if ! $DRY_RUN; then
      jq '
        .hooks.UserPromptSubmit |= [.[] | select(tostring | test("hero-hook") | not)] |
        if .hooks.UserPromptSubmit == [] then del(.hooks.UserPromptSubmit) else . end |
        if .hooks == {} then del(.hooks) else . end
      ' "$SETTINGS" >"$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
    fi
    removed=$((removed + 1))
  else
    skipped=$((skipped + 1))
  fi
fi

# Reset hero-hook.sh to its placeholder state
HOOK_SCRIPT="$SCRIPT_DIR/hero-hook.sh"
if [[ -f "$HOOK_SCRIPT" ]] && ! grep -q 'REPLACE_ME' "$HOOK_SCRIPT"; then
  action "Reset hero-hook.sh to placeholder"
  if ! $DRY_RUN; then
    # Replace the user's custom command with the original placeholder.
    # The line sits between "# YOUR COMMAND:" block and the closing "# ===" line.
    sed -i '' '/^# YOUR COMMAND:/,/^# ===/{
      /^# /!c\
echo "hero: REPLACE_ME - edit hero-hook.sh with your command" >>/tmp/hero-hook-log.txt
    }' "$HOOK_SCRIPT"
  fi
  removed=$((removed + 1))
else
  skipped=$((skipped + 1))
fi

# --- Level 7: hero-knowledge skill ---
echo "Level 7 - The Skill Quest of Doom:"
remove_dir_contents "$CLAUDE_DIR/skills/hero-knowledge" "hero-knowledge skill" "SKILL.md"

# --- Level 8: hero-agent ---
echo "Level 8 - The Summoner's Circle:"
remove_file "$CLAUDE_DIR/agents/hero-agent.md" "hero-agent.md"

# --- Level 9: hero plugin directories ---
# Only removes plugin.json from directories that are actually hero plugins.
# Uses rmdir for cleanup (safe -- refuses non-empty dirs). Never rm -rf.
echo "Level 9 - The Artificer's Workshop:"
LEVEL9_FOUND=false
for candidate in hero-toolkit hero-plugin claude-code-hero-plugin; do
  for base in "." "$HOME"; do
    manifest="$base/$candidate/.claude-plugin/plugin.json"
    if [[ -f "$manifest" ]] && grep -qi 'hero' "$manifest"; then
      action "Remove plugin manifest ($manifest)"
      if ! $DRY_RUN; then
        rm "$manifest"
        rmdir "$base/$candidate/.claude-plugin" 2>/dev/null || true
        rmdir "$base/$candidate" 2>/dev/null || true
      fi
      removed=$((removed + 1))
      LEVEL9_FOUND=true
    fi
  done
done
$LEVEL9_FOUND || skipped=$((skipped + 1))

# --- Reset progress file ---
echo ""
echo "Progress:"
action "Reset claude-code-hero.json to level 1"
if ! $DRY_RUN; then
  echo '{"current_level": 1, "completed": {}}' >"$PROGRESS_FILE"
fi

# --- Clean up hook log ---
if [[ -f /tmp/hero-hook-log.txt ]]; then
  action "Remove /tmp/hero-hook-log.txt"
  $DRY_RUN || rm /tmp/hero-hook-log.txt
fi

echo ""
echo "================================="
if $DRY_RUN; then
  echo "Dry run complete. Would remove $removed artifact(s), skip $skipped already-clean."
  echo "Run without --dry-run to execute."
else
  echo "Restart complete. Removed $removed artifact(s), $skipped already clean."
  echo "The dungeon awaits. Start fresh with: claude --agent heroguide"
fi
