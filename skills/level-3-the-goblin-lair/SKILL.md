---
name: level-3-the-goblin-lair
description: "Claude Code Hero Level 3: The Goblin Lair of Commands -- create a custom slash command in ~/.claude/commands/"
---

## Objective

Create a custom **slash command** in `~/.claude/commands/` with valid YAML frontmatter and a useful prompt body.

## Why This Matters

You've written standing orders in CLAUDE.md. But some tasks don't belong in permanent instructions -- they're things you do repeatedly, on demand. Slash commands turn multi-line prompts into single invocations. Type `/your-command` and the whole prompt fires. They're the simplest extension point Claude Code offers, and once you've built one, you'll build a dozen.

## The Quest

You descend a narrow staircase. The air thickens. Somewhere below, you hear them -- goblins. Dozens of them, doing the same tedious work over and over. Running the same prompts. Copying the same boilerplate. Repeating the same instructions that could be written once and invoked forever.

Your weapon against this horde: a **slash command**.

Create a `.md` file in `~/.claude/commands/`. It must have:

- **YAML frontmatter** between `---` markers containing at least a `description` field
- A **prompt body** below the frontmatter -- the actual instruction that runs when the command is invoked
- A name that reflects what it does (the filename becomes the command name: `review.md` becomes `/review`)

The command should do something you'd actually use. Some ideas:

- A code review command that checks for specific patterns
- A commit message generator that follows your conventions
- A test writer that matches your project's style
- A refactoring assistant with your preferred approach

**Bonus objective**: Use `$ARGUMENTS` in your prompt body to accept dynamic input. This placeholder gets replaced with whatever the user types after the command name. `/review the auth module` would replace `$ARGUMENTS` with "the auth module".

## Hints

### Hint 1

The file goes in `~/.claude/commands/`. If the directory doesn't exist, create it. The filename (minus `.md`) becomes the command name.

### Hint 2

The frontmatter needs at least `description`. Here's the skeleton:

```
---
description: What this command does (shows up in the command list)
---
```

Other useful frontmatter fields: `allowed-tools` to restrict which tools the command can use, `model` to specify a particular model.

### Hint 3

Here's a complete example:

```markdown
---
description: Generate a conventional commit message for staged changes
---

Look at the staged changes with `git diff --cached` and write a commit message following conventional commit format (feat:, fix:, refactor:, etc.).

Keep the first line under 72 characters. Add a body only if the change needs explanation.

$ARGUMENTS
```

Your command should reflect something you'd genuinely use -- not this example verbatim.

## Verification

### Filesystem Check

- Path: `~/.claude/commands/*.md`
- Command: `ls ~/.claude/commands/*.md 2>/dev/null`
- At least one `.md` file must exist in the directory

### Content Check

- The file has valid YAML frontmatter (content between `---` delimiters at the top)
- Frontmatter contains at least a `description` field with a real description (not empty, not "test")
- The body below the frontmatter contains a meaningful prompt
- Bonus: uses `$ARGUMENTS` for dynamic input (noted but not required to pass)

## Connection

The goblins scatter. Where repetition once ruled, a single word now carries your intent.

Notice the `---` markers at the top of your command? That incantation -- **YAML frontmatter** -- appears in every spell in this realm. Commands, output styles, skills, agents -- they all begin the same way. Remember this pattern. You'll see it again.

Next, you'll learn who holds the keys to what powers flow through this realm.
