#!/usr/bin/env bats
# Tests for scripts/startup.sh -- JSON operations via jq
# Each test uses an isolated $HOME in a tmp directory.

SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../scripts" && pwd)"

setup() {
  export HOME="$(mktemp -d)"
  mkdir -p "$HOME/.claude"
  PROGRESS_FILE="$HOME/.claude/claude-code-hero.json"
}

teardown() {
  rm -rf "$HOME"
}

# --- Initialization ---

@test "creates progress file when missing" {
  run bash "$SCRIPT_DIR/startup.sh"
  [ "$status" -eq 0 ]
  [ -f "$PROGRESS_FILE" ]
}

@test "new progress file has current_level 1" {
  bash "$SCRIPT_DIR/startup.sh" >/dev/null
  level=$(jq '.current_level' "$PROGRESS_FILE")
  [ "$level" -eq 1 ]
}

@test "new progress file has empty completed object" {
  bash "$SCRIPT_DIR/startup.sh" >/dev/null
  completed=$(jq '.completed' "$PROGRESS_FILE")
  [ "$completed" = "{}" ]
}

# --- Reading existing state ---

@test "reads existing progress file without overwriting" {
  cat > "$PROGRESS_FILE" <<'EOF'
{"current_level": 5, "completed": {"1": "2026-01-01T00:00:00Z", "2": "2026-01-02T00:00:00Z"}}
EOF
  output=$(bash "$SCRIPT_DIR/startup.sh")
  echo "$output" | jq -e '.current_level == 5'
}

# --- Reconciliation with verify.sh ---

@test "advances current_level when artifacts exist ahead of progress" {
  # Level 1 artifact: hero-map.md with 3 headings
  cat > "$HOME/.claude/hero-map.md" <<'EOF'
## Heading One
Content
## Heading Two
Content
## Heading Three
Content
EOF
  # Progress file says level 1 (hasn't completed anything)
  echo '{"current_level": 1, "completed": {}}' > "$PROGRESS_FILE"

  output=$(bash "$SCRIPT_DIR/startup.sh")
  new_level=$(echo "$output" | jq '.current_level')
  [ "$new_level" -eq 2 ]
}

@test "backfills completed timestamps for passing levels" {
  cat > "$HOME/.claude/hero-map.md" <<'EOF'
## Heading One
Content
## Heading Two
Content
## Heading Three
Content
EOF
  echo '{"current_level": 1, "completed": {}}' > "$PROGRESS_FILE"

  bash "$SCRIPT_DIR/startup.sh" >/dev/null
  # Level 1 should now have a completed timestamp
  has_level_1=$(jq 'has("completed") and (.completed | has("1"))' "$PROGRESS_FILE" 2>/dev/null || echo "false")
  [ "$has_level_1" = "true" ]
}

@test "backfilled timestamp is ISO 8601 UTC format" {
  cat > "$HOME/.claude/hero-map.md" <<'EOF'
## Heading One
Content
## Heading Two
Content
## Heading Three
Content
EOF
  echo '{"current_level": 1, "completed": {}}' > "$PROGRESS_FILE"

  bash "$SCRIPT_DIR/startup.sh" >/dev/null
  ts=$(jq -r '.completed["1"]' "$PROGRESS_FILE")
  # Should match YYYY-MM-DDTHH:MM:SSZ
  [[ "$ts" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$ ]]
}

@test "does not overwrite existing completed timestamps" {
  cat > "$HOME/.claude/hero-map.md" <<'EOF'
## Heading One
Content
## Heading Two
Content
## Heading Three
Content
EOF
  echo '{"current_level": 1, "completed": {"1": "2025-12-25T00:00:00Z"}}' > "$PROGRESS_FILE"

  bash "$SCRIPT_DIR/startup.sh" >/dev/null
  ts=$(jq -r '.completed["1"]' "$PROGRESS_FILE")
  [ "$ts" = "2025-12-25T00:00:00Z" ]
}

# --- JSON output ---

@test "outputs valid JSON" {
  output=$(bash "$SCRIPT_DIR/startup.sh")
  echo "$output" | jq -e . >/dev/null
}

@test "output contains required fields" {
  output=$(bash "$SCRIPT_DIR/startup.sh")
  echo "$output" | jq -e '.current_level' >/dev/null
  echo "$output" | jq -e '.completed' >/dev/null
  echo "$output" | jq -e '.highest_passing' >/dev/null
  echo "$output" | jq -e '.status' >/dev/null
}

@test "status is 'new' for fresh start" {
  output=$(bash "$SCRIPT_DIR/startup.sh")
  status=$(echo "$output" | jq -r '.status')
  [ "$status" = "new" ]
}

@test "status is 'in_progress' for partially completed" {
  cat > "$HOME/.claude/hero-map.md" <<'EOF'
## Heading One
Content
## Heading Two
Content
## Heading Three
Content
EOF
  echo '{"current_level": 1, "completed": {}}' > "$PROGRESS_FILE"

  output=$(bash "$SCRIPT_DIR/startup.sh")
  status=$(echo "$output" | jq -r '.status')
  [ "$status" = "in_progress" ]
}

@test "highest_passing reflects verify.sh results" {
  output=$(bash "$SCRIPT_DIR/startup.sh")
  hp=$(echo "$output" | jq '.highest_passing')
  [ "$hp" -eq 0 ]
}

# --- Prerequisites ---

@test "fails with clear message when jq is not available" {
  # Create a temp bin dir with only bash, hiding jq
  local fake_bin="$(mktemp -d)"
  ln -s "$(command -v bash)" "$fake_bin/bash"
  ln -s "$(command -v date)" "$fake_bin/date"
  ln -s "$(command -v seq)" "$fake_bin/seq"
  ln -s "$(command -v mkdir)" "$fake_bin/mkdir"
  ln -s "$(command -v cat)" "$fake_bin/cat"
  ln -s "$(command -v echo)" "$fake_bin/echo"
  ln -s "$(command -v test)" "$fake_bin/test"
  ln -s "$(command -v grep)" "$fake_bin/grep"
  ln -s "$(command -v wc)" "$fake_bin/wc"
  ln -s "$(command -v tr)" "$fake_bin/tr"
  ln -s "$(command -v awk)" "$fake_bin/awk"
  ln -s "$(command -v head)" "$fake_bin/head"
  ln -s "$(command -v find)" "$fake_bin/find"

  run env PATH="$fake_bin" bash "$SCRIPT_DIR/startup.sh"
  rm -rf "$fake_bin"
  [ "$status" -ne 0 ]
  [[ "$output" == *"jq"* ]]
}
