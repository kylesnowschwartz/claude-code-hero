---
name: verify
description: "Verify your current Claude Code Hero quest level. Use when the learner types /verify, asks to check their work, or wants to see quest progress."
argument-hint: "[level-number]"
allowed-tools: Bash, Read
---

Verify quest completion for Claude Code Hero. Do not perform semantic evaluation -- the script is the source of truth.

If the user provided a level number ($ARGUMENTS), verify that specific level. Otherwise, read `~/.claude/claude-code-hero.json` to find `current_level` and verify that.

Run: `bash scripts/verify.sh $ARGUMENTS`

Report the result:
- **PASS**: State what was verified and that the level is complete. Keep it brief.
- **FAIL**: Show the failure message from the script so the user knows what to fix.

## Per-Level Artifact Reference

Each level checks for a quest-specific artifact. Generic artifacts (e.g., any command, any skill) do not count -- the learner must create the exact artifact the quest instructs them to build.

| Level | Quest | Artifact | What the Script Checks |
|-------|-------|----------|----------------------|
| 1 | The Map Room | ~/.claude/hero-map.md | File exists, has at least 3 `## ` headings |
| 2 | The Tome | ~/.claude/CLAUDE.md | Contains `## Hero's Decree` section with at least 3 non-empty lines |
| 3 | The Goblin Lair | ~/.claude/commands/hero-spell.md | Has YAML frontmatter with `description` field and uses `$ARGUMENTS` |
| 4 | The Warden's Keys | ~/.claude/settings.json | Contains `Bash(git:` in permissions |
| 5 | The Shapeshifter's Mask | ~/.claude/output-styles/hero-voice.md | Has frontmatter with `name` and `description` |
| 6 | The Tripwire Cavern | ~/.claude/settings.json | Contains `"hooks"` section and `hero` in a command |
| 7 | The Skill Quest | ~/.claude/skills/hero-knowledge/SKILL.md | Has frontmatter with `name` and `description` |
| 8 | The Summoner's Circle | ~/.claude/agents/hero-agent.md | Has `description` in frontmatter and `<example>` block |
| 9 | The Artificer's Workshop | plugin with "hero" in name | `.claude-plugin/plugin.json` with "hero" in name, plus at least one component directory |

## Reconciliation Logic

When verifying, check ALL levels, not just the current one. The learner may have created artifacts ahead of where the progress file says they are.

### Steps

1. Read the progress file to get `current_level`.
2. Run `bash scripts/verify.sh` to check all levels.
3. Parse the PASS/FAIL output for each level.
4. Find the highest consecutively completed level starting from 1.
5. If that level is higher than `current_level`, update the progress file to match.

### Example

Progress file says `current_level: 1`. The script reports PASS for levels 1, 2, 3, and 4 (but FAIL for 5). Set `current_level` to 5 -- the next level to attempt.

If levels 1, 2, and 4 pass but level 3 fails, set `current_level` to 3. Level 4's artifact is noted but doesn't advance progress past the gap.

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
- **COMPLETE** -- script reports PASS
- **CURRENT** -- this is where the learner is working; include the FAIL message from the script
- **LOCKED** -- not yet reached (levels beyond CURRENT)

If a locked level already has a PASS result, note it:

```
Level 5: The Shapeshifter's Mask -- LOCKED (artifact found -- will count when reached)
```

## Caveats

**Levels 4 and 6 both use settings.json.** They check different content (permissions.allow vs hooks) and can be completed independently. A settings.json with permissions but no hooks passes level 4 and fails level 6.
