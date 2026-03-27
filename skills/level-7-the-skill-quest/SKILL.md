---
name: level-7-the-skill-quest
description: "Claude Code Hero Level 7: The Skill Quest of Doom -- create a skill directory with SKILL.md in ~/.claude/skills/"
---

## Objective

Create a **skill** at `~/.claude/skills/hero-knowledge/SKILL.md` with real domain knowledge inside it.

## Why This Matters

Commands wait to be called by name. Output styles shape every word. But skills are something different. They're knowledge that activates on its own. Claude reads the description, recognizes the moment, and summons the skill without being asked.

Think of it this way: a slash command is a spell you cast. A skill is instinct -- expertise that surfaces when the situation demands it. You don't invoke a skill. You create the conditions, and it appears.

Skills also support **progressive disclosure**. A `SKILL.md` can reference deeper material in `references/` and `examples/` subdirectories, letting Claude pull in exactly as much context as the moment requires. Light guidance for simple questions. Deep expertise for complex ones.

## The Quest

Beyond the cavern of tripwires, a library. Not the dusty kind. This one breathes. Scrolls drift from shelves when a question is asked, returning when the answer is given. Knowledge that serves the seeker without being summoned.

You're going to build one of these scrolls. Every scroll in this library bears a name. Yours is `hero-knowledge`.

You've built a spell, a voice, and a tripwire. Now bind your actual expertise into a tome that Claude can summon when the moment is right.

Pick a domain you know well. It could be a language, a framework, a workflow, an internal tool, a set of conventions your team follows. Something where you regularly explain the same patterns to Claude. Frame it as your hero's domain knowledge -- the thing you're the expert on.

Then forge it:

- Create `~/.claude/skills/hero-knowledge/SKILL.md`
- Add **YAML frontmatter** with `name` and `description` fields -- the `description` is what Claude reads to decide when this skill is relevant, so write it like a trigger condition
- Write the skill body: the knowledge, patterns, conventions, or instructions Claude should follow when this domain comes up
- Test it by asking Claude a question that should activate the skill

The `description` field does the heavy lifting. It tells Claude when to reach for this knowledge. "Use when writing Ruby test files" is specific. "Ruby stuff" is not. Write it like you're telling a colleague when to open a particular reference doc.

**Optional**: Create a `references/` or `examples/` subdirectory with deeper material the skill can draw from.

## Hints

### Hint 1

The directory structure is what matters. A skill is a folder inside `~/.claude/skills/` containing a `SKILL.md` file. Yours goes in `hero-knowledge/`.

```
~/.claude/skills/
  hero-knowledge/
    SKILL.md
```

### Hint 2

The frontmatter needs `name` and `description`. The description drives auto-activation -- Claude reads it and decides whether to load the skill based on context.

```markdown
---
name: rails-testing
description: "Use when writing or reviewing Rails test files. Covers RSpec conventions, factory patterns, and test organization for our Rails monolith."
---

Your skill content here.
```

### Hint 3

Here's a complete, minimal example:

```markdown
---
name: go-error-handling
description: "Use when writing Go code that handles errors. Covers error wrapping, sentinel errors, and the team's convention of using fmt.Errorf with %w."
---

# Go Error Handling Conventions

Always wrap errors with context using `fmt.Errorf`:

    return fmt.Errorf("fetching user %d: %w", id, err)

Never discard errors silently. If you intentionally ignore one, assign to `_` with a comment explaining why.

Use sentinel errors for conditions callers need to check:

    var ErrNotFound = errors.New("not found")

Check with `errors.Is`, not string comparison.
```

To test: start a new Claude session and ask a question in the skill's domain. If the skill activates, you'll see its knowledge reflected in the response. If it doesn't, sharpen the `description` -- make it more specific about when to trigger.

## Verification

### Filesystem Check

- Path: `~/.claude/skills/hero-knowledge/SKILL.md`
- Command: `test -f ~/.claude/skills/hero-knowledge/SKILL.md && echo "exists" || echo "missing"`

### Content Check

- The file has valid YAML frontmatter (content between `---` delimiters at the top)
- Frontmatter contains a `name` field with a non-empty value
- Frontmatter contains a `description` field with a non-empty value -- and the description reads like a trigger condition, not a vague label
- The body below the frontmatter contains actual skill content (not empty, not placeholder text)

## Connection

The scroll drifts back to its shelf. But it remembers you now. Next time the question arises, it will find you.

Stop for a moment. Look at what you just built. A directory. A `SKILL.md`. Frontmatter with `name` and `description`. A body of instructions.

The quest you're reading right now? It's a `SKILL.md`. The verification that checks your work? Also a `SKILL.md`. You just forged the same thing that's been guiding you through this dungeon. The sage builds with the same tools the sage was built from.

Count the artifacts on your belt. A command (`hero-spell`). A voice (`hero-voice`). A hook that connects them. And now a skill (`hero-knowledge`). Four components. Each one built with the same frontmatter pattern. Each one a different kind of power.

One more companion to summon before the final forge.
