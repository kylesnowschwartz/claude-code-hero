---
name: level-2-the-tome
description: "Claude Code Hero Level 2: The Tome of First Instructions -- create .claude/CLAUDE.md with real personal instructions"
---

## Objective

Create or update `.claude/CLAUDE.md` with a `## Hero's Decree` section containing at least three real instructions you want Claude to follow in every session.

## Why This Matters

**CLAUDE.md** is the single most important file in your Claude Code setup. Claude reads it at the start of every session -- before your first message, before any tool runs, before anything else happens. The instructions you write here shape every interaction. One file, permanent influence.

## The Quest

Behind a case you overlooked the first time, you find an empty tome. Its pages are blank, but the binding hums with potential. An inscription on the cover reads: *What is written here governs all that follows.*

This is your **CLAUDE.md** -- and it's your character sheet.

Every hero has one. Class. Abilities. Fighting style. Values. The sheet defines who you are and how you operate. Without it, you're a generic adventurer. With it, every ally who fights alongside you knows your strengths, your preferences, and your code.

Your task: fill in the sheet.

### What to write

Create `.claude/CLAUDE.md` (or open it if it already exists) and add a section with this exact heading:

```
## Hero's Decree
```

Under that heading, write at least three directives that define how you operate. These should be real preferences -- the things that make you *you* as a developer:

- **Your class**: What languages and frameworks do you fight with? TypeScript strict mode? Rails conventions? Go idioms?
- **Your fighting style**: Terse or detailed responses? Ask before making changes, or move fast? How should Claude handle uncertainty?
- **Your code**: Test frameworks, commit message formats, naming conventions, tools you reach for first?

Write what you mean. Claude will follow it. A few lines that matter are worth more than a page of filler. But don't hold back if you have strong opinions -- the tome has room.

### Try it

Before you verify, test your character sheet. Type `/exit` to end this session, then run `claude` to start a fresh one. Ask Claude about one of your preferences -- coding style, communication, whatever you wrote. It should follow your instructions. That's the CLAUDE.md working. Then run `claude --continue` to pick up where you left off here.

## Hints

### Hint 1

The file goes at `.claude/CLAUDE.md`. Plain Markdown. No special syntax required -- just write what you want Claude to do. The heading must be exactly `## Hero's Decree` (the verifier checks for it).

### Hint 2

Think about what frustrates you in AI interactions. Do you hate over-explanation? Say so. Do you want Claude to always run tests before committing? Write it down. The best character sheets are opinionated.

### Hint 3

Here's a minimal example to get you started:

```markdown
# My Instructions

## Hero's Decree
- Use TypeScript with strict mode for all new files
- Keep responses concise -- no preamble, no summaries unless asked
- Always run `npm test` after making changes to source files
```

Your version should reflect your actual preferences, not this example.

## Verification

When you're ready, run `/verify` to check your work.

### Filesystem Check

- Path: `.claude/CLAUDE.md`
- Command: `test -f .claude/CLAUDE.md && echo "exists" || echo "missing"`

### Content Check

- Command: `grep -q "Hero's Decree" .claude/CLAUDE.md && echo "found" || echo "missing"`
- The file contains a `## Hero's Decree` section (exact heading text)
- The section contains at least three distinct directives (separate instructions, not one instruction spread across three lines)
- Content reflects real preferences, not placeholder text like "hello", "test", or "asdf"
- The bar is intent: if the learner wrote instructions they actually plan to use, it passes

## Further Reading

- [Memory and CLAUDE.md](https://docs.anthropic.com/en/docs/claude-code/memory) -- official docs on CLAUDE.md files, instruction hierarchy, and auto memory

## Connection

Your character sheet is filed. Every session, Claude reads your decree first -- it knows your class, your style, your code.

But a hero who must speak every command aloud wastes their breath. What if you could inscribe reusable spells -- single words that invoke entire sequences?
