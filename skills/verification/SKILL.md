---
name: verification
description: "Claude Code Hero level verification -- checks whether quest objectives have been met by inspecting the filesystem for artifacts"
---

# Verification Skill

Check whether a learner has completed quest levels by inspecting their filesystem for artifacts. Each level has specific existence and content requirements.

## Per-Level Verification Registry

| Level | Quest | Artifact Path | Filesystem Check | Content Check |
|-------|-------|--------------|-----------------|---------------|
| 1 | The Map Room | N/A (knowledge-based) | Progress file shows level >= 2 | Agent evaluates learner's answers about ~/.claude/ structure |
| 2 | The Tome | ~/.claude/CLAUDE.md | `test -f ~/.claude/CLAUDE.md` | Contains at least 3 real directives (not placeholder like "hello" or "test") |
| 3 | The Goblin Lair | ~/.claude/commands/*.md | At least one .md file in ~/.claude/commands/ | Has YAML frontmatter with at least `description` field |
| 4 | The Warden's Keys | ~/.claude/settings.json | File exists and contains permission rules | Has at least one custom entry in `permissions.allow` array |
| 5 | The Shapeshifter's Mask | ~/.claude/output-styles/*.md | At least one .md file in ~/.claude/output-styles/ | Has YAML frontmatter with `name` and `description` |
| 6 | The Tripwire Cavern | ~/.claude/settings.json hooks | settings.json contains `hooks` section | At least one hook configured with an event and handler |
| 7 | The Skill Quest | ~/.claude/skills/*/SKILL.md | At least one SKILL.md in a subdirectory | Has frontmatter with `name` and `description` |
| 8 | The Summoner's Circle | Agent .md file | An agent .md file exists (in any project) | Has frontmatter with `description` containing `<example>` blocks |
| 9 | The Artificer's Workshop | .claude-plugin/plugin.json | plugin.json exists in a learner-created directory | Contains at least `name` field, plus one component (command, skill, agent, or hook) |

## Running Checks

Use these tools for each check type:

**Filesystem existence** -- Bash tool with `test -f <path>` or `ls <glob>`:
- Single file: `test -f ~/.claude/CLAUDE.md && echo "exists"`
- Glob match: `ls ~/.claude/commands/*.md 2>/dev/null`
- Directory scan: `ls ~/.claude/skills/*/SKILL.md 2>/dev/null`

**Content inspection** -- Read tool:
- Read the file and inspect its contents directly
- For JSON files (settings.json), check that expected keys and values are present
- For Markdown files, check for YAML frontmatter between `---` delimiters

**Pattern matching** -- Grep and Glob tools:
- Use Grep to search for specific keys, fields, or patterns within files
- Use Glob to find files matching a path pattern (e.g., `~/.claude/skills/*/SKILL.md`)

**Semantic quality** -- Agent evaluation:
- For content checks, evaluate whether the content demonstrates real understanding
- A CLAUDE.md with three lines saying "be nice", "use tabs", "no emojis" counts. Three lines of "test", "hello", "asdf" do not.
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

Progress file says `current_level: 1`. Checks find valid artifacts for levels 2, 3, and 4 (but not 5). The learner's CLAUDE.md exists with real content, they have a command with frontmatter, and settings.json has a permissions.allow entry.

Since levels 1-4 are all satisfied (level 1 was previously completed to reach level 2), set `current_level` to 5 -- the next level to attempt.

If levels 1, 2, and 4 pass but level 3 does not, set `current_level` to 3. Level 4's artifact is noted but doesn't advance progress past the gap.

## Reporting Format

Output a status line for each level:

```
Level 1: The Map Room         -- COMPLETE
Level 2: The Tome             -- COMPLETE
Level 3: The Goblin Lair      -- CURRENT (missing: no .md files found in ~/.claude/commands/)
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

**Level 8 artifacts can live anywhere.** Agent .md files are not restricted to ~/.claude/. The learner might create one in any project directory. When checking level 8, ask the learner where their agent file is, or check common locations like the current working directory.

**Level 9 is a new directory.** The learner creates a fresh plugin directory with a plugin.json manifest. This is not a modification of existing ~/.claude/ files. The directory could be anywhere the learner chooses.

**Levels 4 and 6 both use settings.json.** They check different sections (permissions.allow vs hooks) and can be completed independently. A settings.json with permissions but no hooks passes level 4 and fails level 6.
