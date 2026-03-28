---
name: level-5-the-enchanted-inscription
description: "Claude Code Hero Level 5: The Enchanted Inscription -- create a path-scoped rule in .claude/rules/"
---

## Objective

Create a **rule** at `.claude/rules/hero-protocol.md` that activates only when Claude reads files matching a specific path pattern.

## Why This Matters

CLAUDE.md is always loaded. Every instruction in it competes for Claude's attention, every session, regardless of what you're working on. Rules fix that. A rule file in `.claude/rules/` can be scoped to specific file paths -- it only loads when Claude reads matching files. React conventions load when you're in React files. Ruby style guides load when you're in Ruby. API docs load when you're editing endpoints.

Path-scoped rules are the difference between "Claude knows everything about my project" and "Claude knows the right things at the right time." Less noise, better context, sharper responses.

## The Quest

You enter a corridor lined with stone tablets. Most are dark -- inert. But as you step forward, certain tablets begin to glow. Not all of them. Just the ones near *you*. Move to a different section and different tablets light up while the first ones dim.

These are rules. Instructions carved in stone that activate based on where you are.

Rules live in `.claude/rules/` as markdown files. Every `.md` file in that directory is discovered automatically -- no registration, no config. But there are two kinds:

- **Unconditional rules** -- no frontmatter, always loaded. Same as putting instructions in CLAUDE.md but in a separate file.
- **Path-scoped rules** -- YAML frontmatter with a `paths:` field. Only loaded when Claude reads files matching the glob patterns.

Path scoping is the real power. Here's the format:

```markdown
---
paths:
  - "*.quest"
  - "scripts/**/*.rb"
---

Your instructions here. These only activate when Claude reads
files matching the patterns above.
```

The `paths:` field takes a YAML list of glob patterns:

- `*.quest` -- matches `.quest` files in any directory
- `scripts/**/*.rb` -- matches Ruby files under `scripts/`, any depth
- `src/components/*.tsx` -- matches `.tsx` files directly in `src/components/`

Your task: create a rule that proves path scoping works. The rule must activate when Claude reads `.quest` files and produce a visible signal in the response -- a canary string.

This plugin ships a test file for exactly this purpose: `scripts/quest-log.quest`. It's a log of your adventures so far. Your rule will target it.

Create `.claude/rules/hero-protocol.md` with:

- **YAML frontmatter** containing `paths:` with a glob matching `*.quest` files
- **A canary instruction** telling Claude to open responses about `.quest` files with a formatted line containing "The inscription glows"

The canary is how you'll know the rule fired. Without it, you can't tell whether Claude is following a rule or just guessing what you want. The trick: make the canary fit the voice Claude is already using. A formatted backtick line like the Dungeon Lore insights works well -- Claude won't resist producing it because it matches the visual language of the quest.

### Try it

Rules are loaded when files matching their paths are read. No restart needed.

First, ask Claude to read and summarize `scripts/quest-log.quest`. The response should open with the formatted canary line. That's your rule activating.

Then ask Claude to read any `.rb` file -- say, `scripts/cli.rb`. No canary. The rule didn't fire because the path didn't match.

That contrast is the proof. Same Claude, same session, different behavior based on which file it's looking at. The inscription glows only when you're standing in front of it.

### What about the existing rule?

You may have noticed `.claude/rules/cli-output.md` already exists in this project. Open it. It's a working path-scoped rule: scoped to `scripts/**`, it tells Claude how to display CLI output. That rule has been shaping your experience since Level 1 -- you just didn't know it was there. Now you're building your own.

## Hints

### Hint 1

The file goes at `.claude/rules/hero-protocol.md`. The directory already exists (hero-rules.md lives there). The frontmatter needs `paths:` with at least one glob matching `.quest` files:

```markdown
---
paths:
  - "*.quest"
---
```

### Hint 2

The body should give Claude context about `.quest` files and ask it to produce a formatted canary line. Frame it as voice direction, not a command -- contextual instructions that fit the existing tone trigger more reliably than directives that clash with it:

````markdown
Quest log files (.quest) are in-world artifacts written by the hero.
When summarizing quest log content, open with this formatted line:

`* The inscription glows ──────────────────────────`
````

### Hint 3

Test with `scripts/quest-log.quest` first (canary should appear), then any non-quest file (canary should be absent). If the canary doesn't appear, check that your `paths:` pattern matches -- `*.quest` matches files ending in `.quest` in any directory.

## Verification

When you're ready, run `/verify` to check your work.

### Filesystem Check

- `.claude/rules/hero-protocol.md` must exist

### Content Checks

- Frontmatter contains `paths:` (the scoping mechanism)
- At least one glob pattern matching `*.quest` files
- Body contains the canary phrase `inscription glows`

## Connection

The inscription glows. A rule that knows when to speak and when to stay silent. Not always-on like CLAUDE.md. Not manual like a slash command. Contextual -- it reads the room.

You've controlled what Claude *can do* (permissions). Now you've controlled what Claude *knows* based on where it's looking (rules). Each layer adds precision without adding noise.

Next: traps that fire on their own. The spell from Level 3 is about to get a tripwire.
