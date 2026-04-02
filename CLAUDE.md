# CLAUDE.md

## What This Is

Claude Code Hero is a Claude Code plugin that teaches Claude Code features through 10 progressive D&D-themed quests (levels 0-9). Each quest teaches one feature (commands, skills, hooks, agents, plugins) by having the learner build a specific artifact. The artifacts interconnect -- the spell from Level 3 gets a hook in Level 6, and everything bundles into a plugin in Level 9.

The medium is the message: the plugin teaches you about plugins by being one.

## Why It Exists

Claude Code has a deep feature surface but a flat onboarding path. Most users plateau at basic chat and CLAUDE.md. Commands, skills, hooks, agents, and plugins go unused because there's no bridge from awareness to competence. This project closes four gaps: discovery, comprehension, motivation, and confidence.

Prior art: Block's "Repo Quest" validated gamified learning for developer tools (RPG tiers for repo setup, +69% AI-authored code after Champions program).

## Architecture

- **Primary interface**: `dungeon-master` agent (`agents/dungeon-master.md`, symlinked to `.claude/agents/`)
- **Level content**: One skill per level (`skills/level-N-<name>/SKILL.md`)
- **Game engine**: `scripts/cli.rb` -- Ruby CLI with declarative level DSL. Each level is a class in `scripts/lib/hero/levels/`. Verification and cleanup logic live alongside metadata.
- **Progress**: `.claude/claude-code-hero.json` -- JSON with `current_level` and `completed` timestamps. Agent reads/writes directly.
- **Voice**: `output-styles/dungeon-master.md` -- D&D dungeon master. Second person, dry wit, drops character for precision.

## Design Decisions

### Quest-specific artifacts
Each level requires a specifically named artifact (`hero-spell.md`, `hero-voice.md`, etc.) rather than checking for generic files. Power users already have commands, skills, and hooks -- generic checks would false-positive on day one.

### Programmatic verification, not semantic
`scripts/cli.rb verify` runs file-existence checks, grep matches, and JSON field inspections. The agent runs the CLI and reports PASS/FAIL. No "does this CLAUDE.md contain real instructions?" judgment calls. Like a learn-to-code tool: run the tests, check the output.

### Interconnected quest arc
Artifacts from earlier levels feed into later ones. Level 3's `/fire-magic-missile` command gets a `UserPromptSubmit` hook in Level 6. Level 9's capstone packages all hero-* artifacts into a plugin. The interconnection makes the progression memorable.

### Filesystem-as-state
Progress lives in `.claude/claude-code-hero.json` (project-scoped, lives alongside the plugin). `userConfig` in plugin.json was tested and found unreliable -- prompting doesn't fire consistently in v2.1.85.

### No ${CLAUDE_PLUGIN_ROOT} in agent/skill markdown
Agent and skill markdown is read by Claude, not expanded as a subprocess. `${CLAUDE_PLUGIN_ROOT}` doesn't expand. Use relative paths (`scripts/cli.rb`, `skills/*/SKILL.md`). The agent can Glob to find files if cwd doesn't match.

## Useful Commands

```bash
# Run the plugin locally (development mode)
claude --plugin-dir . --agent dungeon-master

# Launch the dungeon-master agent directly
claude --agent dungeon-master

# Run verification for all levels
ruby scripts/cli.rb verify

# Run verification for a specific level
ruby scripts/cli.rb verify 3

# Show quest metadata
ruby scripts/cli.rb levels

# Show player progress
ruby scripts/cli.rb status

# Clean all hero artifacts (dry run)
ruby scripts/cli.rb clean --dry-run

# Run tests
ruby -Iscripts/lib -Iscripts/test -e 'Dir["scripts/test/*_test.rb"].each { |f| require File.expand_path(f) }'

# Check what the plugin looks like to Claude Code
claude --plugin-dir . --verbose
```

## Key CLI Flags Learned

| Flag | Purpose |
|------|---------|
| `--plugin-dir .` | Load plugin from local directory (ephemeral, for development) |
| `--agent <name>` | Start session with a specific agent. Resolves: `.claude/agents/` > `~/.claude/agents/` > plugins |
| `--verbose` | Additional debugging output for plugin loading |

## Agent Frontmatter Fields

| Field | Purpose |
|-------|---------|
| `initialPrompt` | Auto-submits a prompt when agent is launched via `--agent`. Only fires for main session agent, not subagents. |
| `model` | Model override. Use `inherit` to match the user's configured model. |
| `color` | UI color badge (blue, cyan, green, yellow, magenta, red). |
| `permissionMode` | Controls permission handling (default, acceptEdits, dontAsk, bypassPermissions, plan, delegate). |

## Plugin Structure

Agents go in `agents/` at plugin root for subagent dispatch. For `--agent` CLI discovery, they also need to be in `.claude/agents/` (project level) or `~/.claude/agents/` (user level). This project symlinks `.claude/agents/dungeon-master.md` -> `agents/dungeon-master.md`.

`marketplace.json` lives in `.claude-plugin/` alongside `plugin.json`. Both are required for full plugin discovery.

## Spec and Discovery Docs

- Spec: `.agent-history/journal/claude-code-hero/02-spec.md`
- Discovery: `.agent-history/journal/claude-code-hero/01-discovery.md`
- Plan: `.agent-history/plans/2026-03-27-claude-code-hero.md`
