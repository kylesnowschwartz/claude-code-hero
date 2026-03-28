---
name: level-9-the-artificers-workshop
description: "Claude Code Hero Level 9: The Artificer's Workshop -- create a minimal Claude Code plugin (capstone)"
---

## Objective

Create a minimal Claude Code **plugin** with a `plugin.json` manifest whose `name` contains "hero", and at least one component.

## Why This Matters

Everything you've built -- commands, rules, hooks, skills, agents -- lives as individual files in individual directories. Useful. Personal. But not portable. A plugin bundles all of it into a single artifact that anyone can install with one command.

Plugins are how Claude Code's ecosystem grows. Someone else's workflow, packaged and shared. Your workflow, packaged and shared. The thing you've been using this entire time -- Claude Code Hero -- is a plugin. You've been inside one since Level 1.

## The Quest

The final chamber. Not a dungeon. A workshop.

Anvil. Forge. Workbench. Shelves lined with components you recognize: commands, rules, skills, hooks, agents. You've built each one separately. Here, they become one thing.

Look at what's on the shelves. You already have:

- A **command**: `hero-spell` -- your magic missile, with `$ARGUMENTS` for targeting
- A **rule**: `hero-protocol` -- the path-scoped inscription you carved in the corridor
- A **hook**: the tripwire that reacts when your spell is cast
- A **skill**: `hero-knowledge` -- dungeon cartography, bound into a tome
- An **agent**: `hero-agent` -- the companion you summoned

Every one of those is a plugin component. You just didn't know it yet.

A **plugin** is a directory with a `.claude-plugin/` folder inside it. That folder contains a `plugin.json` manifest -- the declaration of what this plugin is and what it provides. The components live alongside `.claude-plugin/` as top-level directories: `commands/`, `skills/`, `agents/`, `hooks/`, `rules/`.

Every artifact in this dungeon has carried the hero's mark. Your final creation is no different. The `name` field in your `plugin.json` must contain "hero" -- `hero-toolkit`, `my-hero-plugin`, `hero-utils`, whatever fits. This is how the dungeon knows the artifact is yours.

Your task:

- Create a new directory for your plugin (anywhere on your filesystem)
- Inside it, create `.claude-plugin/plugin.json` with a `name` field containing "hero"
- Copy (or recreate) your hero artifacts into the plugin's directory structure: `commands/hero-spell.md`, `rules/hero-protocol.md`, `skills/hero-knowledge/SKILL.md`, `agents/hero-agent.md`
- Add at least one component (copying all five is the full victory, but one is enough to pass)

### Try it

Launch Claude with your plugin loaded: `claude --plugin-dir <path-to-your-plugin-directory>`. Then test your components. Type `/hero-spell the dragon` -- if the command fires, your plugin is wired correctly. Ask a question in your skill's domain. Launch `claude --agent hero-agent`. Each component that works is proof the plugin structure is right.

If a component doesn't appear, check that the directory names match exactly: `commands/`, `skills/`, `agents/`, `rules/`.

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

The `plugin.json` manifest can be minimal:

```json
{
  "name": "hero-toolkit"
}
```

Other optional fields: `description`, `version`, `author`. But `name` (containing "hero") is all you need to start.

Copy your existing hero artifacts from `.claude/` into the plugin's component directories. They're the same files, same format -- just organized under one roof.

## Verification

When you're ready, run `/verify` to check your work.

### Filesystem Check

- A directory exists containing `.claude-plugin/plugin.json`
- At least one component directory exists alongside `.claude-plugin/` (e.g., `commands/`, `skills/`, `agents/`, `rules/`)
- At least one component file exists inside that directory

### Content Check

- `plugin.json` contains valid JSON
- `plugin.json` includes a `name` field whose value contains "hero" (e.g., `"hero-toolkit"`, `"my-hero-plugin"`)
- At least one component file follows its type's format (frontmatter for commands/skills/agents/styles, valid JSON for hooks)

## Connection

The last rune locks into place. The artifact hums. It's whole.

Look at what's on the workbench. A command that fires magic missiles. A rule that activates by path. A hook that reacts when the spell is cast. A skill that holds your expertise. An agent that acts on its own. And now a plugin that binds them all together.

Everything you built across nine quests -- it was all plugin components. You just didn't know it yet.

## Further Reading

- [Plugins](https://docs.anthropic.com/en/docs/claude-code/plugins) -- official docs on plugin structure, development, and distribution

---

Nine chambers. Nine trials. Each one a power claimed, a pattern learned, a tool forged.

You entered this labyrinth mapping walls. You leave it building them.

The realm of Claude Code has no final chamber. There are marketplaces to discover. Teams to assemble. MCP servers to connect. Worktrees to spin up for parallel work. But those are journeys for another day.

For now: you are an artificer. Go build something.
