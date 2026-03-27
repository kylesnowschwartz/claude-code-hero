#!/usr/bin/env bash
# Claude Code Hero - Level Verification
# Exit codes: 0 = all checked levels pass, 1 = at least one failure
# Usage: bash verify.sh [level]  -- check specific level
#        bash verify.sh           -- check all levels

set -euo pipefail

PASS=0
FAIL=0

check_level_1() {
    # Level 1: Must create ~/.claude/hero-map.md with at least 3 headings
    local file="$HOME/.claude/hero-map.md"
    if [[ ! -f "$file" ]]; then
        echo "FAIL: Level 1 - ~/.claude/hero-map.md does not exist"
        return 1
    fi
    local headings
    headings=$(grep -c '^## ' "$file" 2>/dev/null || echo 0)
    if [[ "$headings" -lt 3 ]]; then
        echo "FAIL: Level 1 - hero-map.md needs at least 3 ## headings (found $headings)"
        return 1
    fi
    echo "PASS: Level 1 - The Map Room"
    return 0
}

check_level_2() {
    # Level 2: ~/.claude/CLAUDE.md must contain "## Hero's Decree" section
    local file="$HOME/.claude/CLAUDE.md"
    if [[ ! -f "$file" ]]; then
        echo "FAIL: Level 2 - ~/.claude/CLAUDE.md does not exist"
        return 1
    fi
    if ! grep -q "## Hero's Decree" "$file"; then
        echo "FAIL: Level 2 - CLAUDE.md missing '## Hero's Decree' section"
        return 1
    fi
    # Must have at least 3 lines of content under the section
    local content_lines
    content_lines=$(awk '/^## Hero'\''s Decree/{found=1; next} found && /^## /{exit} found && NF' "$file" | wc -l | tr -d ' ')
    if [[ "$content_lines" -lt 3 ]]; then
        echo "FAIL: Level 2 - Hero's Decree section needs at least 3 non-empty lines (found $content_lines)"
        return 1
    fi
    echo "PASS: Level 2 - The Tome of First Instructions"
    return 0
}

check_level_3() {
    # Level 3: ~/.claude/commands/hero-spell.md must exist with frontmatter containing description and $ARGUMENTS in body
    local file="$HOME/.claude/commands/hero-spell.md"
    if [[ ! -f "$file" ]]; then
        echo "FAIL: Level 3 - ~/.claude/commands/hero-spell.md does not exist"
        return 1
    fi
    if ! grep -q '^---' "$file"; then
        echo "FAIL: Level 3 - hero-spell.md missing YAML frontmatter (no --- found)"
        return 1
    fi
    if ! grep -q 'description:' "$file"; then
        echo "FAIL: Level 3 - hero-spell.md frontmatter missing 'description' field"
        return 1
    fi
    if ! grep -q '\$ARGUMENTS' "$file"; then
        echo "FAIL: Level 3 - hero-spell.md missing \$ARGUMENTS placeholder"
        return 1
    fi
    echo "PASS: Level 3 - The Goblin Lair of Commands"
    return 0
}

check_level_4() {
    # Level 4: ~/.claude/settings.json must contain Bash(git: in permissions.allow
    local file="$HOME/.claude/settings.json"
    if [[ ! -f "$file" ]]; then
        echo "FAIL: Level 4 - ~/.claude/settings.json does not exist"
        return 1
    fi
    if ! grep -q 'Bash(git:' "$file"; then
        echo "FAIL: Level 4 - settings.json missing 'Bash(git:*)' in permissions"
        return 1
    fi
    echo "PASS: Level 4 - The Warden's Keys"
    return 0
}

check_level_5() {
    # Level 5: ~/.claude/output-styles/hero-voice.md must exist with name and description in frontmatter
    local file="$HOME/.claude/output-styles/hero-voice.md"
    if [[ ! -f "$file" ]]; then
        echo "FAIL: Level 5 - ~/.claude/output-styles/hero-voice.md does not exist"
        return 1
    fi
    if ! grep -q 'name:' "$file"; then
        echo "FAIL: Level 5 - hero-voice.md missing 'name' in frontmatter"
        return 1
    fi
    if ! grep -q 'description:' "$file"; then
        echo "FAIL: Level 5 - hero-voice.md missing 'description' in frontmatter"
        return 1
    fi
    echo "PASS: Level 5 - The Shapeshifter's Mask"
    return 0
}

check_level_6() {
    # Level 6: ~/.claude/settings.json must contain hooks section with hero in a command
    local file="$HOME/.claude/settings.json"
    if [[ ! -f "$file" ]]; then
        echo "FAIL: Level 6 - ~/.claude/settings.json does not exist"
        return 1
    fi
    if ! grep -q '"hooks"' "$file"; then
        echo "FAIL: Level 6 - settings.json missing 'hooks' section"
        return 1
    fi
    if ! grep -q 'hero' "$file"; then
        echo "FAIL: Level 6 - settings.json hooks section missing 'hero' in command"
        return 1
    fi
    echo "PASS: Level 6 - The Tripwire Cavern"
    return 0
}

check_level_7() {
    # Level 7: ~/.claude/skills/hero-knowledge/SKILL.md must exist with name and description
    local file="$HOME/.claude/skills/hero-knowledge/SKILL.md"
    if [[ ! -f "$file" ]]; then
        echo "FAIL: Level 7 - ~/.claude/skills/hero-knowledge/SKILL.md does not exist"
        return 1
    fi
    if ! grep -q 'name:' "$file"; then
        echo "FAIL: Level 7 - SKILL.md missing 'name' in frontmatter"
        return 1
    fi
    if ! grep -q 'description:' "$file"; then
        echo "FAIL: Level 7 - SKILL.md missing 'description' in frontmatter"
        return 1
    fi
    echo "PASS: Level 7 - The Skill Quest of Doom"
    return 0
}

check_level_8() {
    # Level 8: An agent file named hero-agent.md with description containing <example>
    # Check both project and user agent directories
    local found=0
    for dir in ".claude/agents" "$HOME/.claude/agents"; do
        local file="$dir/hero-agent.md"
        if [[ -f "$file" ]]; then
            found=1
            if ! grep -q 'description:' "$file"; then
                echo "FAIL: Level 8 - hero-agent.md missing 'description' in frontmatter"
                return 1
            fi
            if ! grep -q '<example>' "$file"; then
                echo "FAIL: Level 8 - hero-agent.md missing <example> block"
                return 1
            fi
            echo "PASS: Level 8 - The Summoner's Circle"
            return 0
        fi
    done
    echo "FAIL: Level 8 - hero-agent.md not found in .claude/agents/ or ~/.claude/agents/"
    return 1
}

check_level_9() {
    # Level 9: A plugin directory with .claude-plugin/plugin.json containing "hero" in name
    # Search in common locations
    local found=0
    for candidate in hero-toolkit hero-plugin claude-code-hero-plugin; do
        for base in "." "$HOME"; do
            local manifest="$base/$candidate/.claude-plugin/plugin.json"
            if [[ -f "$manifest" ]]; then
                if grep -q '"name"' "$manifest" && grep -qi 'hero' "$manifest"; then
                    found=1
                    # Check for at least one component
                    local plugin_dir
                    plugin_dir=$(dirname "$(dirname "$manifest")")
                    local has_component=0
                    [[ -d "$plugin_dir/commands" ]] && has_component=1
                    [[ -d "$plugin_dir/skills" ]] && has_component=1
                    [[ -d "$plugin_dir/agents" ]] && has_component=1
                    [[ -d "$plugin_dir/hooks" ]] && has_component=1
                    if [[ "$has_component" -eq 0 ]]; then
                        echo "FAIL: Level 9 - Plugin found but has no component directories (commands/, skills/, agents/, or hooks/)"
                        return 1
                    fi
                    echo "PASS: Level 9 - The Artificer's Workshop"
                    return 0
                fi
            fi
        done
    done
    echo "FAIL: Level 9 - No plugin with 'hero' in name found"
    return 1
}

# Main
LEVEL="${1:-all}"

if [[ "$LEVEL" == "all" ]]; then
    for i in $(seq 1 9); do
        if check_level_$i; then
            PASS=$((PASS + 1))
        else
            FAIL=$((FAIL + 1))
        fi
    done
    echo "---"
    echo "$PASS passed, $FAIL failed out of 9 levels"
    [[ "$FAIL" -eq 0 ]] && exit 0 || exit 1
else
    check_level_$LEVEL
fi
