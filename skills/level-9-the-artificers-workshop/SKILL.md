---
name: level-9-the-artificers-workshop
description: "Claude Code Hero Level 9: The Artificer's Workshop -- create a minimal Claude Code plugin (capstone)"
---

## Objective

Create a minimal Claude Code **plugin** with a `plugin.json` manifest whose `name` contains "hero", and at least one component.

## Why This Matters

Everything you've built -- commands, output styles, hooks, skills, agents -- lives as individual files in individual directories. Useful. Personal. But not portable. A plugin bundles all of it into a single artifact that anyone can install with one command.

Plugins are how Claude Code's ecosystem grows. Someone else's workflow, packaged and shared. Your workflow, packaged and shared. The thing you've been using this entire time -- Claude Code Hero -- is a plugin. You've been inside one since Level 1.

## The Quest

The final chamber. Not a dungeon. A workshop.

Anvil. Forge. Workbench. Shelves lined with components you recognize: commands, skills, hooks, agents, output styles. You've built each one separately. Here, they become one thing.

Look at what's on the shelves. You already have:

- A **command**: `hero-spell` -- your magic missile, with `$ARGUMENTS` for targeting
- An **output style**: `hero-voice` -- the mask you forged in the Shapeshifter's chamber
- A **hook**: the tripwire that reacts when your spell is cast
- A **skill**: `hero-knowledge` -- your domain expertise, bound into a tome
- An **agent**: `hero-agent` -- the companion you summoned

Every one of those is a plugin component. You just didn't know it yet.

A **plugin** is a directory with a `.claude-plugin/` folder inside it. That folder contains a `plugin.json` manifest -- the declaration of what this plugin is and what it provides. The components live alongside `.claude-plugin/` as top-level directories: `commands/`, `skills/`, `agents/`, `hooks/`, `output-styles/`.

Every artifact in this dungeon has carried the hero's mark. Your final creation is no different. The `name` field in your `plugin.json` must contain "hero" -- `hero-toolkit`, `my-hero-plugin`, `hero-utils`, whatever fits. This is how the dungeon knows the artifact is yours.

Your task:

- Create a new directory for your plugin (anywhere on your filesystem)
- Inside it, create `.claude-plugin/plugin.json` with a `name` field containing "hero"
- Copy (or recreate) your hero artifacts into the plugin's directory structure: `commands/hero-spell.md`, `output-styles/hero-voice.md`, `skills/hero-knowledge/SKILL.md`, `agents/hero-agent.md`
- Add at least one component (copying all five is the full victory, but one is enough to pass)
- Test it by running `claude --plugin-dir <path-to-your-plugin-directory>`
- Verify Claude recognizes your components

You already know how to build every component type. You've done it across five quests. Now bind them together and watch them come alive as a distributable package.

## Hints

### Hint 1

A plugin is just a directory. The magic is in the structure:

```
my-plugin/
  .claude-plugin/
    plugin.json
  commands/
    my-command.md
```

The `.claude-plugin/plugin.json` file is the manifest. Everything else follows the same patterns you've already learned.

### Hint 2

The `plugin.json` manifest can be minimal. At its simplest:

```json
{
  "name": "hero-toolkit"
}
```

Other optional fields: `description`, `version`, `author`. But `name` (containing "hero") is all you need to start.

Components go in their standard directories at the plugin root -- the same directories your hero artifacts already live in:
- `commands/hero-spell.md` -- your magic missile from Level 3
- `output-styles/hero-voice.md` -- your voice from Level 5
- `skills/hero-knowledge/SKILL.md` -- your domain expertise from Level 7
- `agents/hero-agent.md` -- your companion from Level 8

### Hint 3

Here's the full hero plugin structure with all your artifacts:

```
hero-toolkit/
  .claude-plugin/
    plugin.json
  commands/
    hero-spell.md
  output-styles/
    hero-voice.md
  skills/
    hero-knowledge/
      SKILL.md
  agents/
    hero-agent.md
```

`plugin.json`:
```json
{
  "name": "hero-toolkit",
  "description": "My first Claude Code plugin -- assembled from quest artifacts",
  "version": "0.1.0"
}
```

You can copy your existing artifacts from `~/.claude/` into the plugin directory. They're the same files -- just organized under one roof.

To test: `claude --plugin-dir /path/to/hero-toolkit`

Then try invoking `/hero-spell the dragon` or asking a question in your skill's domain. If it works, you've built a plugin from the components you forged across nine quests.

## Verification

When you're ready, run `/verify` to check your work.

### Filesystem Check

- A directory exists containing `.claude-plugin/plugin.json`
- At least one component directory exists alongside `.claude-plugin/` (e.g., `commands/`, `skills/`, `agents/`, `output-styles/`)
- At least one component file exists inside that directory

### Content Check

- `plugin.json` contains valid JSON
- `plugin.json` includes a `name` field whose value contains "hero" (e.g., `"hero-toolkit"`, `"my-hero-plugin"`)
- At least one component file follows its type's format (frontmatter for commands/skills/agents/styles, valid JSON for hooks)

## Connection

The last rune locks into place. The artifact hums. It's whole.

Look at what's on the workbench. A command that fires magic missiles. A voice that shapes every response. A hook that reacts when the spell is cast. A skill that holds your expertise. An agent that acts on its own. And now a plugin that binds them all together.

Everything you built across nine quests -- it was all plugin components. You just didn't know it yet.

---

Nine chambers. Nine trials. Each one a power claimed, a pattern learned, a tool forged.

You entered this labyrinth mapping walls. You leave it building them.

The realm of Claude Code has no final chamber. There are marketplaces to discover. Teams to assemble. MCP servers to connect. Worktrees to spin up for parallel work. But those are journeys for another day.

For now: you are an artificer. Go build something.
