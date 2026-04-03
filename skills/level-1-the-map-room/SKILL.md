---
name: level-1-the-map-room
description: "Claude Code Hero Level 1: The Map Room -- explore the project's .claude/ directory and document what lives there"
---

## Objective

Explore this project's `.claude/` directory and create a map documenting its key components -- settings, commands, agents, rules, and how they relate to the global `~/.claude/`.

## Why This Matters

Everything in Claude Code is configured through files in a handful of directories. Before you write your first instruction or forge your first command, you need to know where things live and what they do. This is the foundation every other level builds on.

Most Claude Code users never learn that there are *two* configuration directories -- one for the project, one for you. Understanding both is understanding the whole system.

## The Quest

You push open a heavy door. Beyond it, a vast chamber -- the Map Room. Its walls are lined with alcoves, each containing a different kind of artifact. Some are familiar. Others are inscribed with patterns you don't yet recognize.

Your task: explore this project's `.claude/` directory and write a map of what you find. Not a surface glance. A real survey, written down so you can refer back to it.

Start by listing what's inside `.claude/`. You can ask the dungeon master to look for you ("what's in the .claude directory?"), or type a shell command directly into the prompt box -- Claude will run it:

```
ls -la .claude/
```

Everything in Claude Code goes through the prompt. Questions, commands, requests -- all in the same place. There's no separate terminal to open.

Then dig into each thing you find. Read files. Ask questions about what you see. Understand their structure.

Here's what to investigate:

- What does **`settings.json`** contain? What is it controlling? Is there another settings file nearby, and how do they differ?
- Where do **custom slash commands** live? Find the one in `.claude/commands/`. What does its **YAML frontmatter** do? What fields does it have?
- What's in **`agents/`**? What does the file there look like? Where does it point?
- What's in **`rules/`**? What does the frontmatter's `paths` field do? How is a rule different from a command?
- What else lives in `.claude/`? Anything unexpected?

Use whatever tools make sense. Read files directly. Poke around. The Map Room rewards the curious.

### The Mirror

Here's the thing most adventurers miss: this project's `.claude/` directory has a twin.

Your home directory has `~/.claude/` -- the **global** configuration. Same structure, different scope. Project-level `.claude/` applies only to this project. Global `~/.claude/` applies everywhere.

When both exist, they merge. Project settings layer on top of global ones. A permission allowed globally can be denied at project level. A command defined globally is available in every session. A command defined in `.claude/commands/` only appears in this project.

Your map should cover both: what you found in `./.claude/`, and how `~/.claude/` mirrors it at the global level.

### Write the Map

Create `.claude/hero-map.md` and document what you discovered. Your map needs at least three sections (using `## ` headings), each covering a different part of what you learned. Structure it however makes sense to you -- by directory, by concept, by scope.

## Hints

### Hint 1

Start with `ls .claude/`. The directory names are descriptive. Open each file you find and read it. Create your map file at `.claude/hero-map.md` with `## ` headings for each area you explore.

### Hint 2

Commands are Markdown files with YAML between `---` markers at the top. Read the one in `.claude/commands/`. The frontmatter fields control how the command appears and behaves. The body is the prompt that runs when you invoke it. Rules are similar but load automatically -- you don't invoke them.

### Hint 3

`settings.json` holds permissions and preferences. Look for the `permissions` key and the `allow` array. Notice there's also a `settings.local.json` -- that's a personal override file (gitignored) that layers on top of the committed `settings.json`. Your map should have sections covering at least three of the things you found.

## Verification

When you're ready, run `/verify` to check your work. The script checks:

- `.claude/hero-map.md` exists
- The file contains at least 3 `## ` headings (sections documenting different parts of what you learned)

## Further Reading

- [Settings and configuration](https://docs.anthropic.com/en/docs/claude-code/settings) -- official docs on project configuration, `.claude/` directory structure, and settings scopes

## Connection

You've mapped the realm. Every corridor, every chamber. You know where commands live, where rules hide, where settings hold their quiet power. And you've seen the mirror -- project and global, two reflections of the same structure.

But a map without a decree is just paper.

It's time to write your first law.
