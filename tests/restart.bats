#!/usr/bin/env bats
# Tests for scripts/restart.sh -- JSON (jq) and text (sed) operations
# Each test uses an isolated $HOME in a tmp directory.

SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../scripts" && pwd)"

setup() {
  export HOME="$(mktemp -d)"
  mkdir -p "$HOME/.claude"
  SETTINGS="$HOME/.claude/settings.json"
  CLAUDE_MD="$HOME/.claude/CLAUDE.md"
  PROGRESS_FILE="$HOME/.claude/claude-code-hero.json"
  echo '{"current_level": 5, "completed": {"1": "2026-01-01T00:00:00Z"}}' > "$PROGRESS_FILE"
}

teardown() {
  rm -rf "$HOME"
}

# ========================================
# Level 2: Hero's Decree removal from CLAUDE.md
# ========================================

@test "removes Hero's Decree section from CLAUDE.md" {
  cat > "$CLAUDE_MD" <<'EOF'
## About Me
Some personal content here.

## Hero's Decree
I decree that all code shall be tested.
And that dragons shall not be trusted.
For the realm depends on clean commits.

## Other Section
More content here.
EOF
  bash "$SCRIPT_DIR/restart.sh"
  ! grep -q "Hero's Decree" "$CLAUDE_MD"
}

@test "preserves other sections when removing Hero's Decree" {
  cat > "$CLAUDE_MD" <<'EOF'
## About Me
Some personal content here.

## Hero's Decree
I decree that all code shall be tested.
And that dragons shall not be trusted.

## Other Section
More content here.
EOF
  bash "$SCRIPT_DIR/restart.sh"
  grep -q "## About Me" "$CLAUDE_MD"
  grep -q "## Other Section" "$CLAUDE_MD"
  grep -q "More content here." "$CLAUDE_MD"
}

@test "handles Hero's Decree at end of file" {
  cat > "$CLAUDE_MD" <<'EOF'
## About Me
Some personal content here.

## Hero's Decree
I decree that all code shall be tested.
EOF
  bash "$SCRIPT_DIR/restart.sh"
  ! grep -q "Hero's Decree" "$CLAUDE_MD"
  grep -q "## About Me" "$CLAUDE_MD"
}

@test "no-ops gracefully when CLAUDE.md has no Hero's Decree" {
  cat > "$CLAUDE_MD" <<'EOF'
## About Me
Some personal content here.
EOF
  run bash "$SCRIPT_DIR/restart.sh"
  [ "$status" -eq 0 ]
  grep -q "## About Me" "$CLAUDE_MD"
}

# ========================================
# Level 4: Hero permissions removal from settings.json
# ========================================

@test "removes hero permission rules from settings.json" {
  cat > "$SETTINGS" <<'EOF'
{
  "permissions": {
    "allow": ["Bash(git:*)", "Read"],
    "ask": ["Bash(git push:*)", "Write"],
    "deny": ["Bash(git push --force:*)"]
  }
}
EOF
  bash "$SCRIPT_DIR/restart.sh"
  # Hero rules should be gone
  ! jq -e '.permissions.allow[] | select(. == "Bash(git:*)")' "$SETTINGS" 2>/dev/null
  ! jq -e '.permissions.ask[] | select(. == "Bash(git push:*)")' "$SETTINGS" 2>/dev/null
  ! jq -e '.permissions.deny' "$SETTINGS" 2>/dev/null  # deny was only hero rules, should be cleaned
}

@test "preserves non-hero permission rules" {
  cat > "$SETTINGS" <<'EOF'
{
  "permissions": {
    "allow": ["Bash(git:*)", "Read", "Write"],
    "ask": ["Bash(git push:*)", "Edit"]
  }
}
EOF
  bash "$SCRIPT_DIR/restart.sh"
  jq -e '.permissions.allow | index("Read")' "$SETTINGS" >/dev/null
  jq -e '.permissions.allow | index("Write")' "$SETTINGS" >/dev/null
  jq -e '.permissions.ask | index("Edit")' "$SETTINGS" >/dev/null
}

@test "cleans up empty permissions object" {
  cat > "$SETTINGS" <<'EOF'
{
  "permissions": {
    "allow": ["Bash(git:*)"],
    "ask": ["Bash(git push:*)"],
    "deny": ["Bash(git push --force:*)"]
  },
  "other": "preserved"
}
EOF
  bash "$SCRIPT_DIR/restart.sh"
  # All permission tiers were hero-only, so permissions object should be gone
  ! jq -e '.permissions' "$SETTINGS" 2>/dev/null
  jq -e '.other == "preserved"' "$SETTINGS" >/dev/null
}

# ========================================
# Level 6: Hero hook removal from settings.json
# ========================================

@test "removes hero-hook entry from UserPromptSubmit hooks" {
  cat > "$SETTINGS" <<'EOF'
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash /path/to/hero-hook.sh"
          }
        ]
      }
    ]
  }
}
EOF
  bash "$SCRIPT_DIR/restart.sh"
  ! jq -e '.hooks' "$SETTINGS" 2>/dev/null
}

@test "preserves non-hero hooks when removing hero-hook" {
  cat > "$SETTINGS" <<'EOF'
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash /path/to/hero-hook.sh"
          }
        ]
      },
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash /path/to/other-hook.sh"
          }
        ]
      }
    ]
  }
}
EOF
  bash "$SCRIPT_DIR/restart.sh"
  jq -e '.hooks.UserPromptSubmit | length == 1' "$SETTINGS" >/dev/null
  jq -e '.hooks.UserPromptSubmit[0] | tostring | test("other-hook")' "$SETTINGS" >/dev/null
}

# ========================================
# Level 6: hero-hook.sh placeholder reset
# ========================================

@test "resets hero-hook.sh to placeholder" {
  # Simulate a user-edited hero-hook.sh
  cp "$SCRIPT_DIR/hero-hook.sh" "$SCRIPT_DIR/hero-hook.sh.bak"
  sed -i '' 's/REPLACE_ME.*$/say "Magic Missile fired!" >> \/tmp\/hero-hook-log.txt/' "$SCRIPT_DIR/hero-hook.sh"

  bash "$SCRIPT_DIR/restart.sh"
  grep -q 'REPLACE_ME' "$SCRIPT_DIR/hero-hook.sh"

  # Restore original (teardown safety)
  mv "$SCRIPT_DIR/hero-hook.sh.bak" "$SCRIPT_DIR/hero-hook.sh"
}

@test "no-ops when hero-hook.sh already has placeholder" {
  run bash "$SCRIPT_DIR/restart.sh"
  [ "$status" -eq 0 ]
  grep -q 'REPLACE_ME' "$SCRIPT_DIR/hero-hook.sh"
}

# ========================================
# Progress reset
# ========================================

@test "resets progress file to level 1" {
  echo '{"current_level": 7, "completed": {"1":"ts","2":"ts","3":"ts"}}' > "$PROGRESS_FILE"
  bash "$SCRIPT_DIR/restart.sh"
  level=$(jq '.current_level' "$PROGRESS_FILE")
  [ "$level" -eq 1 ]
}

@test "resets completed to empty object" {
  echo '{"current_level": 7, "completed": {"1":"ts","2":"ts","3":"ts"}}' > "$PROGRESS_FILE"
  bash "$SCRIPT_DIR/restart.sh"
  completed=$(jq -c '.completed' "$PROGRESS_FILE")
  [ "$completed" = "{}" ]
}

# ========================================
# Dry run mode
# ========================================

@test "dry-run does not modify files" {
  cat > "$SETTINGS" <<'EOF'
{
  "permissions": {
    "allow": ["Bash(git:*)"]
  },
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [{"type": "command", "command": "bash hero-hook.sh"}]
      }
    ]
  }
}
EOF
  cat > "$CLAUDE_MD" <<'EOF'
## Hero's Decree
Test decree content.
EOF
  echo '{"current_level": 5, "completed": {"1":"ts"}}' > "$PROGRESS_FILE"

  bash "$SCRIPT_DIR/restart.sh" --dry-run
  # Everything should still be there
  grep -q "Hero's Decree" "$CLAUDE_MD"
  jq -e '.permissions.allow[] | select(. == "Bash(git:*)")' "$SETTINGS" >/dev/null
  jq -e '.hooks.UserPromptSubmit' "$SETTINGS" >/dev/null
  level=$(jq '.current_level' "$PROGRESS_FILE")
  [ "$level" -eq 5 ]
}

@test "dry-run outputs what it would do" {
  cat > "$CLAUDE_MD" <<'EOF'
## Hero's Decree
Test decree content.
EOF
  output=$(bash "$SCRIPT_DIR/restart.sh" --dry-run)
  [[ "$output" == *"dry-run"* ]]
}

# ========================================
# Prerequisites
# ========================================

@test "restart fails with clear message when jq is not available" {
  local fake_bin="$(mktemp -d)"
  ln -s "$(command -v bash)" "$fake_bin/bash"
  ln -s "$(command -v date)" "$fake_bin/date"
  ln -s "$(command -v seq)" "$fake_bin/seq"
  ln -s "$(command -v mkdir)" "$fake_bin/mkdir"
  ln -s "$(command -v cat)" "$fake_bin/cat"
  ln -s "$(command -v echo)" "$fake_bin/echo"
  ln -s "$(command -v test)" "$fake_bin/test"
  ln -s "$(command -v grep)" "$fake_bin/grep"
  ln -s "$(command -v sed)" "$fake_bin/sed"
  ln -s "$(command -v rm)" "$fake_bin/rm"
  ln -s "$(command -v rmdir)" "$fake_bin/rmdir"
  ln -s "$(command -v find)" "$fake_bin/find"

  run env PATH="$fake_bin" bash "$SCRIPT_DIR/restart.sh"
  rm -rf "$fake_bin"
  [ "$status" -ne 0 ]
  [[ "$output" == *"jq"* ]]
}
