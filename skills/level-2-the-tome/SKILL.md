---
name: level-2-the-tome
description: "Claude Code Hero Level 2: The Tome of First Instructions -- create ~/.claude/CLAUDE.md with real personal instructions"
---

## Objective

Create or update `~/.claude/CLAUDE.md` with a `## Hero's Decree` section containing at least three real instructions you want Claude to follow in every session.

## Why This Matters

**CLAUDE.md** is the single most important file in your Claude Code setup. Claude reads it at the start of every session -- before your first message, before any tool runs, before anything else happens. The instructions you write here shape every interaction. One file, permanent influence.

## The Quest

Deep in the Map Room, behind a case you overlooked the first time, you find an empty tome. Its pages are blank, but the binding hums with potential. An inscription on the cover reads: *What is written here governs all that follows.*

This is your **CLAUDE.md** -- a file that Claude reads before every session. Your task: inscribe your first decree.

Every ruler names their laws. Yours will live under a heading called `## Hero's Decree`. Create `~/.claude/CLAUDE.md` (or open it if it already exists) and add a section with that exact heading. Inside it, write at least three directives that reflect how you actually want Claude to behave. These should be real preferences, not placeholders.

- **Coding style**: tabs or spaces? Naming conventions? Framework preferences?
- **Communication**: terse or detailed? Should Claude ask before making changes? How should it handle uncertainty?
- **Project conventions**: test frameworks, commit message formats, languages, tools you prefer?

Write what you mean. Claude will follow it.

A few lines that matter are worth more than a page of filler. But don't hold back if you have strong opinions -- the tome has room.

### Try it

Before you verify, test your decree. Type `/exit` to end this session, then run `claude` to start a fresh one. Ask Claude about one of your preferences -- coding style, communication, whatever you wrote. It should follow your instructions. That's the CLAUDE.md working. Then run `claude --continue` to pick up where you left off here.

## Hints

### Hint 1

The file goes at `~/.claude/CLAUDE.md`. Plain Markdown. No special syntax required -- just write what you want Claude to do.

### Hint 2

Think about what frustrates you in AI interactions. Do you hate over-explanation? Say so. Do you want Claude to always run tests before committing? Write it down. The best CLAUDE.md files are opinionated.

### Hint 3

Here's a minimal example to get you started:

```markdown
# My Instructions

- Use TypeScript with strict mode for all new files
- Keep responses concise -- no preamble, no summaries unless asked
- Always run `npm test` after making changes to source files
```

Your version should reflect your actual preferences, not this example.

## Verification

When you're ready, run `/verify` to check your work.

### Filesystem Check

- Path: `~/.claude/CLAUDE.md`
- Command: `test -f ~/.claude/CLAUDE.md && echo "exists" || echo "missing"`

### Content Check

- Command: `grep -q "Hero's Decree" ~/.claude/CLAUDE.md && echo "found" || echo "missing"`
- The file contains a `## Hero's Decree` section (exact heading text)
- The section contains at least three distinct directives (separate instructions, not one instruction spread across three lines)
- Content reflects real preferences, not placeholder text like "hello", "test", or "asdf"
- The bar is intent: if the learner wrote instructions they actually plan to use, it passes

## Connection

Your words are now law. Every session, Claude reads your decree first.

But a ruler who must speak every command aloud wastes their breath. What if you could inscribe reusable spells -- single words that invoke entire sequences?
