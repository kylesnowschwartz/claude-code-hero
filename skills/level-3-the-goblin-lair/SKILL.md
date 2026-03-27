---
name: level-3-the-goblin-lair
description: "Claude Code Hero Level 3: The Goblin Lair of Commands -- create a custom slash command in .claude/commands/"
---

## Objective

Create a custom **slash command** at `.claude/commands/hero-spell.md` with valid YAML frontmatter and a useful prompt body.

## Why This Matters

You've written standing orders in CLAUDE.md. But some tasks don't belong in permanent instructions -- they're things you do repeatedly, on demand. Slash commands turn multi-line prompts into single invocations. Type `/your-command` and the whole prompt fires. They're the simplest extension point Claude Code offers, and once you've built one, you'll build a dozen.

## The Quest

You descend a narrow staircase. The air thickens. Somewhere below, you hear them -- goblins. Dozens of them, doing the same tedious work over and over. Running the same prompts. Copying the same boilerplate. Repeating the same instructions that could be written once and invoked forever.

Your weapon against this horde: a **slash command**.

Every spell needs a name. Yours is `hero-spell` -- but not just any spell. You're forging `/fire-magic-missile`. Create `.claude/commands/hero-spell.md`. It must have:

- **YAML frontmatter** between `---` markers containing a `description` field and an `argument-hint` field
- A **prompt body** below the frontmatter -- the actual instruction that runs when the command is invoked
- **`$ARGUMENTS`** in the prompt body to accept a target

The filename becomes the command name: `hero-spell.md` becomes `/hero-spell`. But a spell without a target is just noise. Use `$ARGUMENTS` so the caster can aim. `/hero-spell the goblin king` should replace `$ARGUMENTS` with "the goblin king".

Your command should generate a dramatic battle message when invoked. Something like: "Describe the casting and impact of a magic missile spell aimed at `$ARGUMENTS`. Be dramatic but brief -- three to four sentences. Include the sound it makes and what happens on impact."

The content is fun, but the mechanism is real. `$ARGUMENTS` is how every serious slash command accepts dynamic input. You'll use this pattern for code review targets, file paths, branch names -- anything you'd pass as an argument.

### Try it

Before you verify, cast the spell. Type `/hero-spell the goblin king` in Claude Code. You should see Claude generate a dramatic battle scene targeting "the goblin king." That's `$ARGUMENTS` at work -- your prompt body with the target swapped in. If the command doesn't appear when you type `/`, the file isn't in the right place or the frontmatter is malformed.

Hold onto this spell. You'll see it again.

## Hints

### Hint 1

The file goes at `.claude/commands/hero-spell.md`. If the directory doesn't exist, create it. The filename (minus `.md`) becomes the command name -- so this becomes `/hero-spell`.

### Hint 2

The frontmatter needs `description` and `argument-hint`:

```
---
description: What this command does (shows up in the command list)
argument-hint: [target]
---

Your prompt body here. Use $ARGUMENTS where the target goes.
```

The `argument-hint` shows up as placeholder text after the command name -- `/hero-spell [target]` in the command list. `$ARGUMENTS` gets replaced with whatever follows the command name: `/hero-spell the goblin king` becomes "the goblin king" in the prompt body.

## Verification

When you're ready, run `/verify` to check your work.

### Filesystem Check

- Path: `.claude/commands/hero-spell.md`
- Command: `test -f .claude/commands/hero-spell.md && echo "exists" || echo "missing"`

### Content Check

- The file has valid YAML frontmatter (content between `---` delimiters at the top)
- Frontmatter contains a `description` field with a real description (not empty, not "test")
- Frontmatter contains an `argument-hint` field (e.g., `[target]`)
- The body below the frontmatter contains a meaningful prompt
- The body uses `$ARGUMENTS` for dynamic input (the spell needs a target)

## Connection

The goblins scatter. Where repetition once ruled, a single word now carries your intent. And that spell you just forged? Keep it close. It has a future you haven't seen yet.

Notice the `---` markers at the top of your command? That incantation -- **YAML frontmatter** -- appears in every spell in this realm. Commands, output styles, skills, agents -- they all begin the same way. Remember this pattern. You'll see it again.

Next, you'll learn who holds the keys to what powers flow through this realm.
