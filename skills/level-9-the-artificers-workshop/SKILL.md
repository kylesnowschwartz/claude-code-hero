---
name: level-9-the-artificers-workshop
description: "Claude Code Hero Level 9: The Artificer's Workshop -- create a minimal Claude Code plugin (capstone)"
---

## Objective

Create a minimal Claude Code **plugin** with a `plugin.json` manifest and at least one component.

## Why This Matters

Everything you've built -- commands, output styles, hooks, skills, agents -- lives as individual files in individual directories. Useful. Personal. But not portable. A plugin bundles all of it into a single artifact that anyone can install with one command.

Plugins are how Claude Code's ecosystem grows. Someone else's workflow, packaged and shared. Your workflow, packaged and shared. The thing you've been using this entire time -- Claude Code Hero -- is a plugin. You've been inside one since Level 1.

## The Quest

The final chamber. Not a dungeon. A workshop.

Anvil. Forge. Workbench. Shelves lined with components you recognize: commands, skills, hooks, agents. You've built each one separately. Here, they become one thing.

A **plugin** is a directory with a `.claude-plugin/` folder inside it. That folder contains a `plugin.json` manifest -- the declaration of what this plugin is and what it provides. The components live alongside `.claude-plugin/` as top-level directories: `commands/`, `skills/`, `agents/`, `hooks/`, `output-styles/`.

Your task:

- Create a new directory for your plugin (anywhere on your filesystem)
- Inside it, create `.claude-plugin/plugin.json` with at least a `name` field
- Add at least one component: a command, skill, agent, or hook
- Test it by running `claude --plugin-dir <path-to-your-plugin-directory>`
- Verify Claude recognizes your component

You already know how to build every component type. You've done it. Now put one (or more) inside a plugin directory structure and watch it come alive as a distributable package.

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
  "name": "my-plugin"
}
```

Other optional fields: `description`, `version`, `author`. But `name` is all you need to start.

Components go in their standard directories at the plugin root:
- `commands/` for slash commands
- `skills/` for skills (each in a subdirectory with `SKILL.md`)
- `agents/` for agent definitions
- `output-styles/` for output styles

### Hint 3

Here's a complete minimal plugin with one command:

```
my-plugin/
  .claude-plugin/
    plugin.json
  commands/
    hello.md
```

`plugin.json`:
```json
{
  "name": "my-plugin",
  "description": "My first Claude Code plugin",
  "version": "0.1.0"
}
```

`commands/hello.md`:
```markdown
---
description: A greeting from my first plugin
---

Say hello and introduce yourself as a component of the user's first plugin. Keep it brief.
```

To test: `claude --plugin-dir /path/to/my-plugin`

Then try invoking your command or triggering your skill. If it works, you've built a plugin.

## Verification

### Filesystem Check

- A directory exists containing `.claude-plugin/plugin.json`
- At least one component directory exists alongside `.claude-plugin/` (e.g., `commands/`, `skills/`, `agents/`, `output-styles/`)
- At least one component file exists inside that directory

### Content Check

- `plugin.json` contains valid JSON
- `plugin.json` includes a `name` field with a non-empty string value
- At least one component file follows its type's format (frontmatter for commands/skills/agents/styles, valid JSON for hooks)

## Connection

The last rune locks into place. The artifact hums. It's whole.

Look at what's on the workbench. Not just a plugin -- a pattern. The same pattern, repeated nine times in nine different forms. Frontmatter and content. Files in the right place. Structure as interface. You've been learning one idea from nine angles.

---

Nine chambers. Nine trials. Each one a power claimed, a pattern learned, a tool forged.

You entered this labyrinth mapping walls. You leave it building them.

The realm of Claude Code has no final chamber. There are marketplaces to discover. Teams to assemble. MCP servers to connect. Worktrees to spin up for parallel work. But those are journeys for another day.

For now: you are an artificer. Go build something.
