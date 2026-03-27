---
name: level-1-the-map-room
description: "Claude Code Hero Level 1: The Map Room -- explore the ~/.claude/ directory and understand what lives there"
---

## Objective

Explore the `~/.claude/` directory and identify its key components -- settings, commands, and plugins.

## Why This Matters

Everything in Claude Code is configured through files in a handful of directories. Before you write your first instruction or forge your first command, you need to know where things live and what they do. This is the foundation every other level builds on.

## The Quest

You push open a heavy door. Beyond it, a vast chamber -- the Map Room. Its walls are lined with alcoves, each containing a different kind of artifact. Some are familiar. Others are inscribed with patterns you don't yet recognize.

Your task: explore `~/.claude/` and report back what you find. Not a surface glance. A real survey.

Answer these questions:

- What does **`settings.json`** contain? Name three settings that look interesting or useful.
- Where do **custom slash commands** live? What directory holds them?
- Find an existing command file. What does its **YAML frontmatter** do? Name at least two fields and what they control.
- Where are **plugins** installed? Pick one and describe what it contains.
- What other directories or files exist in `~/.claude/`? What do they seem to be for?

Use whatever tools make sense. `ls`, `cat`, read files directly. Poke around. The Map Room rewards the curious.

## Hints

### Hint 1

Start with `ls ~/.claude/`. The directory names are descriptive -- they tell you most of what you need to know.

### Hint 2

Commands are Markdown files with YAML between `---` markers at the top. Read one. The frontmatter fields control how the command appears and behaves. The body is the prompt that runs when you invoke it.

### Hint 3

`settings.json` holds permissions, hooks, and preferences. Look for the `permissions` key and the `allow`/`deny` arrays. Plugins live in a directory inside `~/.claude/` -- each one has its own folder with a manifest file called `plugin.json`.

## Verification

### Knowledge Check

Level 1 is verified conversationally, not by artifact. The learner demonstrates understanding by answering the quest questions. Evaluate their responses against these criteria:

- **settings.json**: Can name at least three real settings (permissions, hooks, model preferences, API configuration, etc.). Invented or vague answers do not count.
- **Commands directory**: Correctly identifies `~/.claude/commands/` as the location for custom slash commands.
- **Frontmatter fields**: Can name at least two real fields from a command's YAML frontmatter (e.g., `name`, `description`, `allowed-tools`, `model`).
- **Plugins**: Can identify where plugins are stored and describe at least one plugin's contents at a basic level.
- **Other directories**: Names at least one other directory or file in `~/.claude/` and offers a reasonable explanation of its purpose.

The bar is understanding, not perfection. If they explored and can speak to what they found, they pass.

## Connection

You've mapped the realm. Every corridor, every chamber. But a map without a decree is just paper.

It's time to write your first law.
