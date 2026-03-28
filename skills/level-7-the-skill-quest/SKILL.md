---
name: level-7-the-skill-quest
description: "Claude Code Hero Level 7: The Skill Quest of Doom -- create a skill directory with SKILL.md in .claude/skills/"
---

## Objective

Create a **skill** at `.claude/skills/hero-knowledge/SKILL.md` that Claude activates automatically when the context matches.

## Why This Matters

Commands wait to be called by name. Rules activate by file path. But skills are something different. They're knowledge that activates on its own. Claude reads the description, recognizes the moment, and summons the skill without being asked.

Think of it this way: a slash command is a spell you cast. A skill is instinct -- expertise that surfaces when the situation demands it. You don't invoke a skill. You create the conditions, and it appears.

## The Quest

Beyond the cavern of tripwires, a library. Not the dusty kind. This one breathes. Scrolls drift from shelves when a question is asked, returning when the answer is given. Knowledge that serves the seeker without being summoned.

You're going to build one of these scrolls. Every scroll in this library bears a name. Yours is `hero-knowledge`.

Your hero has been mapping dungeons since Level 1. Time to formalize that instinct. You'll create a skill that draws ASCII dungeon maps -- a cartography scroll that activates when someone asks to map, draw, or visualize a dungeon.

A skill has three parts:

1. **The directory**: `.claude/skills/hero-knowledge/`
2. **The file**: `SKILL.md` inside that directory
3. **The frontmatter**: `name` and `description` fields that tell Claude *when* to activate

The `description` field does the heavy lifting. It tells Claude when to reach for this knowledge. Write it like a trigger condition:

- Good: `"Use when the user asks to draw, map, or visualize a dungeon layout. Generates ASCII dungeon maps."`
- Bad: `"Dungeon stuff"`

Create `.claude/skills/hero-knowledge/SKILL.md` with:

- **YAML frontmatter** with `name` (matching the directory: `hero-knowledge`) and a `description` that triggers on map/dungeon/cartography requests
- **A body** that instructs Claude how to draw an ASCII dungeon map -- rooms, corridors, a legend, the hero's position marked with `@`

Here's a starting point for the body:

````markdown
---
name: hero-knowledge
description: "Use when the user asks to draw, map, or visualize a dungeon. Generates ASCII dungeon maps with rooms, corridors, and a legend."
---

# Dungeon Cartography

When asked to draw or map a dungeon, generate an ASCII map using these conventions:

- `#` for walls
- `.` for floor
- `+` for doors
- `@` for the hero's position
- Letters (A, B, C) to label rooms

Include a legend below the map explaining what each symbol means.

Example:

```
  #####+#####
  #....#....#
  #.A..+..B.#
  #....#..@.#
  #####+#####
```

Scale the map to fit the request. A "small dungeon" is 3-4 rooms.
A "large dungeon" is 8+. Default to medium (5-6 rooms) if unspecified.
````

### Try it

Two ways to test, and you should try both:

1. **Let Claude find it.** Say "draw me a dungeon map" or "map this dungeon." Watch for Claude to invoke the Skill tool automatically. An ASCII map should appear using the conventions from your skill.

2. **Invoke it directly.** Type `/hero-knowledge` in Claude Code. The skill content loads into the conversation. Then ask for a map -- Claude will follow the instructions you wrote.

If auto-activation doesn't fire, sharpen the `description`. The description is the trigger -- Claude matches it against the current conversation to decide whether to load the skill.

## Hints

### Hint 1

A skill is a folder inside `.claude/skills/` containing a `SKILL.md` file:

```
.claude/skills/
  hero-knowledge/
    SKILL.md
```

### Hint 2

The frontmatter needs `name` and `description`. The description drives auto-activation -- write it like you're telling a colleague when to open a reference doc:

```markdown
---
name: hero-knowledge
description: "Use when the user asks to draw, map, or visualize a dungeon. Generates ASCII dungeon maps with rooms, corridors, and a legend."
---
```

### Hint 3

If auto-activation doesn't fire, the `description` might be too vague. Try being more specific about trigger words: "draw", "map", "visualize", "dungeon layout", "cartography."

## Verification

When you're ready, run `/verify` to check your work.

### Filesystem Check

- Path: `.claude/skills/hero-knowledge/SKILL.md`

### Content Check

- Frontmatter contains a `name` field
- Frontmatter contains a `description` field

## Connection

The scroll drifts back to its shelf. But it remembers you now. Next time someone asks for a map, it will find them.

The quest you're reading right now? It's a `SKILL.md`. The verification that checks your work? Also a `SKILL.md`. You just forged the same thing that's been guiding you through this dungeon.

Count the artifacts on your belt. A command (`hero-spell`). A rule (`hero-protocol`). A hook that connects them. And now a skill (`hero-knowledge`). Four components. Each one a different kind of power.

One more companion to summon before the final forge.
