---
name: verification
description: "Claude Code Hero level verification -- checks whether quest objectives have been met by inspecting the filesystem for artifacts"
---

# Verification Skill

Check whether a learner has completed quest levels by inspecting their filesystem for artifacts. Each level has specific existence and content requirements.

## Per-Level Verification Registry

Each level checks for a quest-specific artifact. Generic artifacts (e.g., any command, any skill) do not count -- the learner must create the exact artifact the quest instructs them to build. This prevents false positives for power users who already have these files.

| Level | Quest | Artifact | Filesystem Check | Content Check |
|-------|-------|----------|-----------------|---------------|
| 1 | The Map Room | N/A (knowledge-based) | Progress file shows level >= 2 | Agent evaluates learner's answers about ~/.claude/ structure |
| 2 | The Tome | ~/.claude/CLAUDE.md | `test -f ~/.claude/CLAUDE.md` | Contains a `## Hero's Decree` section with real directives inside it |
| 3 | The Goblin Lair | ~/.claude/commands/hero-spell.md | `test -f ~/.claude/commands/hero-spell.md` | Has YAML frontmatter with `description` field and a meaningful prompt body |
| 4 | The Warden's Keys | ~/.claude/settings.json | `grep -q "Bash(git:" ~/.claude/settings.json` | `permissions.allow` contains `Bash(git:*)` (the specific rule the quest teaches) |
| 5 | The Shapeshifter's Mask | ~/.claude/output-styles/hero-voice.md | `test -f ~/.claude/output-styles/hero-voice.md` | Has YAML frontmatter with `name` and `description`, plus style instructions in body |
| 6 | The Tripwire Cavern | ~/.claude/settings.json hooks | `grep -q "hero" ~/.claude/settings.json` | A hook exists with "hero" in its command string (e.g., a log path or script name) |
| 7 | The Skill Quest | ~/.claude/skills/hero-knowledge/SKILL.md | `test -f ~/.claude/skills/hero-knowledge/SKILL.md` | Has frontmatter with `name` and `description` and real skill content |
| 8 | The Summoner's Circle | ~/.claude/agents/hero-agent.md | `test -f ~/.claude/agents/hero-agent.md` | Has frontmatter with `description` containing `<example>` blocks and a system prompt body |
| 9 | The Artificer's Workshop | plugin with "hero" in name | Find a `.claude-plugin/plugin.json` where `name` contains "hero" | Contains `name` field with "hero" in the value, plus at least one component |

## Running Checks

Use these tools for each check type:

**Filesystem existence** -- Bash tool with `test -f <path>` or `grep`:
- Single file: `test -f ~/.claude/CLAUDE.md && echo "exists"`
- Named file: `test -f ~/.claude/commands/hero-spell.md && echo "exists"`
- Content match: `grep -q "Hero's Decree" ~/.claude/CLAUDE.md && echo "found"`
- Pattern in JSON: `grep -q "hero" ~/.claude/settings.json && echo "found"`

**Content inspection** -- Read tool:
- Read the file and inspect its contents directly
- For JSON files (settings.json), check that expected keys and values are present
- For Markdown files, check for YAML frontmatter between `---` delimiters

**Pattern matching** -- Grep and Glob tools:
- Use Grep to search for specific keys, fields, or patterns within files
- Use Glob to find files matching a path pattern (e.g., `~/.claude/skills/*/SKILL.md`)

**Semantic quality** -- Agent evaluation:
- For content checks, evaluate whether the content demonstrates real understanding
- A `## Hero's Decree` section with lines like "use tabs", "no emojis", "run tests before committing" counts. A section with "test", "hello", "asdf" does not.
- A command with a description like "Run project tests" counts. A description of "my command" does not.
- The bar is intent, not polish. If the learner tried to make something real, it passes.

## Reconciliation Logic

When verifying, check ALL levels, not just the current one. The learner may have created artifacts ahead of where the progress file says they are.

### Steps

1. Read the progress file to get `current_level`.
2. Run filesystem and content checks for every level (1 through 9).
3. Build a list of which levels have passing artifacts.
4. Find the highest consecutively completed level starting from 1.
5. If that level is higher than `current_level`, update the progress file to match.

### Example

Progress file says `current_level: 1`. Checks find valid artifacts for levels 2, 3, and 4 (but not 5). The learner's CLAUDE.md has a `## Hero's Decree` section, `hero-spell.md` exists with frontmatter, and settings.json contains `Bash(git:`.

Since levels 1-4 are all satisfied (level 1 was previously completed to reach level 2), set `current_level` to 5 -- the next level to attempt.

If levels 1, 2, and 4 pass but level 3 does not, set `current_level` to 3. Level 4's artifact is noted but doesn't advance progress past the gap.

## Reporting Format

Output a status line for each level:

```
Level 1: The Map Room         -- COMPLETE
Level 2: The Tome             -- COMPLETE
Level 3: The Goblin Lair      -- CURRENT (missing: ~/.claude/commands/hero-spell.md not found)
Level 4: The Warden's Keys    -- LOCKED
Level 5: The Shapeshifter's Mask -- LOCKED
Level 6: The Tripwire Cavern  -- LOCKED
Level 7: The Skill Quest      -- LOCKED
Level 8: The Summoner's Circle -- LOCKED
Level 9: The Artificer's Workshop -- LOCKED
```

Statuses:
- **COMPLETE** -- artifact verified, checks pass
- **CURRENT** -- this is where the learner is working; include what specifically is missing
- **LOCKED** -- not yet reached (levels beyond CURRENT)

If a locked level already has a valid artifact, note it:

```
Level 5: The Shapeshifter's Mask -- LOCKED (artifact found -- will count when reached)
```

## Caveats

**Level 1 is knowledge-based.** There is no artifact to check. It can only be marked complete by the heroguide agent during a guided session where the learner demonstrates understanding of the ~/.claude/ directory structure. During reconciliation, if the progress file already shows level >= 2, treat level 1 as complete.

**Level 8 checks a specific file.** The quest instructs the learner to create `~/.claude/agents/hero-agent.md`. Check that exact path.

**Level 9 requires "hero" in the plugin name.** The learner creates a fresh plugin directory with a plugin.json manifest. The `name` field in plugin.json must contain "hero". The directory could be anywhere the learner chooses -- search common locations or ask.

**Levels 4 and 6 both use settings.json.** They check different sections (permissions.allow vs hooks) and can be completed independently. A settings.json with permissions but no hooks passes level 4 and fails level 6.
