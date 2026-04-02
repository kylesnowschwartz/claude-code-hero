---
name: level-0-the-threshold
description: "Claude Code Hero Level 0: The Threshold -- learn the basics of talking to Claude Code before entering the dungeon"
---

## Objective

Learn the three things every Claude Code user needs: how to give an instruction, how to point Claude at a file, and how to ask Claude to create something. Then prove it by having Claude write your first artifact.

## Why This Matters

Claude Code is a conversational tool. You type instructions in the prompt box at the bottom of the screen, press Enter, and Claude acts. That's the entire interaction model. But most people never learn the small things that make it work well -- like referencing specific files or giving clear, direct instructions.

This level is about building that muscle memory before you need it.

## The Quest

You stand at the threshold of the dungeon. The door is sealed -- not by a lock, but by a simple test. The dungeon does not open for those who cannot speak its language.

Your trial has three parts.

### Part 1: Speak

Type a message in the prompt box and press Enter. That's it. Ask Claude something about this project -- what files are here, what the project does, anything. Watch what happens.

The prompt box is at the bottom of the screen. You type, you press Enter (or Return), Claude responds. If you want to cancel a response in progress, press **Escape** twice.

### Part 2: Point

Now try something more specific. Use the **@** symbol to reference a file by name. Type `@` and you'll see a list of files you can select from. Pick one -- `CLAUDE.md` is a good choice -- and ask Claude a question about it.

The `@` reference tells Claude to read that specific file before answering. Without it, Claude might guess. With it, Claude knows.

Try it: type something like `what does @CLAUDE.md say about this project?`

### Part 3: Create

Ask Claude to create a file for you. This is the fundamental act -- giving Claude an instruction that produces something real on disk.

Ask Claude to create `.claude/hero-journal.md`. The journal should contain:

- A short entry (a few sentences) about what you've learned so far
- Written as if it's the first page of an adventurer's journal
- At least one `## ` heading

The exact content is yours to decide. The only requirements are that the file exists at `.claude/hero-journal.md` and has some real content in it (not just a heading with nothing under it).

## Hints

### Hint 1

To create the file, just ask Claude directly: "Create a file at `.claude/hero-journal.md` with a journal entry about what I've learned." You can be more specific about what you want in it, or let Claude decide.

### Hint 2

If the file was created but verification fails, make sure it's at the exact path `.claude/hero-journal.md` (not `hero-journal.md` at the project root) and that it has at least 5 lines of real content.

### Hint 3

You can ask Claude to read the file back to you to check: `read @.claude/hero-journal.md and tell me what's in it`.

## Completion

When you're ready, run `/verify` to check your work.

The dungeon checks for one thing: does `.claude/hero-journal.md` exist with real content? If it does, the threshold opens.

## Further Reading

- [Claude Code overview](https://docs.anthropic.com/en/docs/claude-code/overview)
