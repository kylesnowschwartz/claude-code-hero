---
name: level-1-the-map-room
description: "Claude Code Hero Level 1: The Map Room -- explore the ~/.claude/ directory and document what lives there"
---

## Objective

Explore the `~/.claude/` directory and create a map documenting its key components -- settings, commands, plugins, and anything else you find.

## Why This Matters

Everything in Claude Code is configured through files in a handful of directories. Before you write your first instruction or forge your first command, you need to know where things live and what they do. This is the foundation every other level builds on.

## The Quest

You push open a heavy door. Beyond it, a vast chamber -- the Map Room. Its walls are lined with alcoves, each containing a different kind of artifact. Some are familiar. Others are inscribed with patterns you don't yet recognize.

Your task: explore `~/.claude/` and write a map of what you find. Not a surface glance. A real survey, written down so you can refer back to it.

Create the file `~/.claude/hero-map.md` and document what you discover. Your map needs at least three sections (using `## ` headings), each covering a different part of the `~/.claude/` directory.

Here's what to investigate:

- What does **`settings.json`** contain? Name settings that look interesting or useful.
- Where do **custom slash commands** live? What directory holds them?
- Find an existing command file. What does its **YAML frontmatter** do? Name fields and what they control.
- Where are **plugins** installed? Pick one and describe what it contains.
- What other directories or files exist in `~/.claude/`? What do they seem to be for?

Use whatever tools make sense. `ls`, `cat`, read files directly. Poke around. The Map Room rewards the curious. Then write your findings into `~/.claude/hero-map.md`.

## Hints

### Hint 1

Start with `ls ~/.claude/`. The directory names are descriptive -- they tell you most of what you need to know. Create your map file with `## ` headings for each area you explore.

### Hint 2

Commands are Markdown files with YAML between `---` markers at the top. Read one. The frontmatter fields control how the command appears and behaves. The body is the prompt that runs when you invoke it. That's worth a section in your map.

### Hint 3

`settings.json` holds permissions, hooks, and preferences. Look for the `permissions` key and the `allow`/`deny` arrays. Plugins live in a directory inside `~/.claude/` -- each one has its own folder with a manifest file called `plugin.json`. Your map should have sections covering at least three of these areas.

## Verification

Level 1 is verified by the verification script. The script checks:

- `~/.claude/hero-map.md` exists
- The file contains at least 3 `## ` headings (sections documenting different parts of `~/.claude/`)

Run: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/verify.sh 1`

## Connection

You've mapped the realm. Every corridor, every chamber. But a map without a decree is just paper.

It's time to write your first law.
