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
- Add **YAML frontmatter** with `name` and `description` fields. The `name` should match the directory name (`hero-knowledge`), and the `description` is what Claude reads to decide when this skill is relevant, so write it like a trigger condition
- Write the skill body: the knowledge, patterns, conventions, or instructions Claude should follow when this domain comes up
The `description` field does the heavy lifting. It tells Claude when to reach for this knowledge. "Use when writing Ruby test files" is specific. "Ruby stuff" is not. Write it like you're telling a colleague when to open a particular reference doc.

### Try it

Two ways to test your skill, and you should try both:

1. **Invoke it directly.** Type `/hero-knowledge` in Claude Code. The skill content loads into the conversation, just like `/hero-spell` fired your command. You should see your knowledge reflected in Claude's response.

2. **Let Claude find it.** Ask a question in your skill's domain -- something the `description` should match. Watch for Claude to invoke the Skill tool automatically. If it doesn't activate, sharpen the `description` to be more specific about when to trigger.

Skills have two invocation paths: explicit (`/skill-name`) and auto-activation (Claude reads the `description` and invokes it when the context matches). Both use the same Skill tool under the hood.

**Optional**: Create a `references/` or `examples/` subdirectory with deeper material the skill can draw from.

## Hints

### Hint 1

A skill is a folder inside `~/.claude/skills/` containing a `SKILL.md` file:

```
~/.claude/skills/
  hero-knowledge/
    SKILL.md
```

### Hint 2

The frontmatter needs `name` and `description`. The `name` should match the directory name (`hero-knowledge`). The description drives auto-activation.

```markdown
---
name: hero-knowledge
description: "Use when [specific trigger condition]. Covers [what knowledge this provides]."
---

Your skill content here.
```

If auto-activation doesn't fire, sharpen the `description` -- make it more specific about when to trigger.

## Verification

When you're ready, run `/verify` to check your work.

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
