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

A **plugin** is a directory with a `.claude-plugin/` folder inside it. That folder contains a `plugin.json` manifest -- the declaration of what this plugin is and what it provides. The components live alongside `.claude-plugin/` as top-level directories: `commands/`, `skills/`, `agents/`, `rules/`.

Hooks are the exception. They don't get discovered file by file the way commands do -- a plugin declares them in a single `hooks/hooks.json`, holding the same event structure you wrote into `settings.json` back in the Tripwire Cavern, wrapped in a top-level `hooks` key.

Every artifact in this dungeon has carried the hero's mark. Your final creation is no different. The `name` field in your `plugin.json` must contain "hero" -- `hero-toolkit`, `my-hero-plugin`, `hero-utils`, whatever fits. This is how the dungeon knows the artifact is yours.

Your task:

- Create a new directory for your plugin (anywhere on your filesystem)
- Inside it, create `.claude-plugin/plugin.json` with a `name` field containing "hero"
- Copy (or recreate) your hero artifacts into the plugin's directory structure: `commands/hero-spell.md`, `rules/hero-protocol.md`, `skills/hero-knowledge/SKILL.md`, `agents/hero-agent.md`
- Add at least one component (copying all five is the full victory, but one is enough to pass)

### Bonus objective: publish it

This one is optional. The level passes without it, and `/verify` will tell you whether you earned it.

A plugin on your disk is a plugin only you can use. A **marketplace** is the listing that makes it installable by someone else -- the difference between building a thing and shipping it.

A marketplace is one more file next to your manifest: `.claude-plugin/marketplace.json`. It needs three fields:

- **`name`** -- the marketplace's own identifier, kebab-case
- **`owner`** -- an object describing who maintains it. A `name` is enough.
- **`plugins`** -- an array of entries. Each needs a `name` and a `source` saying where to fetch the plugin from.

Since the plugin sits in the same directory as the marketplace, its source is just `"./"`:

```json
{
  "name": "hero-marketplace",
  "owner": { "name": "Your Name" },
  "plugins": [
    {
      "name": "hero-toolkit",
      "source": "./",
      "description": "A toolkit forged in the dungeons"
    }
  ]
}
```

The `name` in that entry must contain "hero" -- same mark every artifact in this dungeon carries.

One marketplace can list many plugins, and that's the usual reason to build one: a team publishes a single marketplace, and everyone installs from it with `/plugin marketplace add`. Yours lists one plugin. The shape is identical either way.

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

### Bonus Check (optional)

Not required to pass. `/verify` reports whether you earned it.

- `.claude-plugin/marketplace.json` exists next to your `plugin.json` and is valid JSON
- It has a `name` string and an `owner` object
- Its `plugins` array holds at least one entry with a hero name and a `source`

## Connection

The last rune locks into place. The artifact hums. It's whole.

Look at what's on the workbench. A command that fires magic missiles. A rule that activates by path. A hook that reacts when the spell is cast. A skill that holds your expertise. An agent that acts on its own. And now a plugin that binds them all together.

Everything you built across the quests behind you -- it was all plugin components. You just didn't know it yet.

## Further Reading

- [Plugins](https://docs.anthropic.com/en/docs/claude-code/plugins) -- official docs on plugin structure, development, and distribution

---

Chamber after chamber. Each one a power claimed, a pattern learned, a tool forged.

You entered this labyrinth mapping walls. You leave it building them.

The workshop was the point. Everything before it was a component; everything after it is something you can hand to another person. Whatever you build next, you now know how to package it.

You are an artificer. Go build something.
