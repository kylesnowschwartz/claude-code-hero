---
name: level-5-the-shapeshifters-mask
description: "Claude Code Hero Level 5: The Shapeshifter's Mask -- create a custom output style in ~/.claude/output-styles/"
---

## Objective

Create a custom **output style** at `~/.claude/output-styles/hero-voice.md` and activate it in your settings.

## Why This Matters

Output styles control how Claude communicates. Tone, structure, verbosity, formatting -- all of it. You've been experiencing one this entire time. The voice guiding you through these quests? That's an output style. A markdown file with frontmatter and instructions, sitting in a directory, shaping every word you've read.

Now you build your own.

## The Quest

You enter a chamber of masks. They line the walls, each one different. One speaks in terse commands. Another in long, careful explanations. A third in bullet points and nothing else.

You've been hearing a voice since you entered this dungeon. Steady. Second person. Dry. That voice is wearing a mask too.

Look at it: `output-styles/heroguide.md` in this plugin's directory. Open it. Read it. That's the mask you've been listening to. An `.md` file with **YAML frontmatter** and a body of instructions. The same pattern you used to build a slash command in Level 3.

Now forge your own. Every mask needs a name. Yours is `hero-voice`.

- Create `~/.claude/output-styles/hero-voice.md`
- Add **YAML frontmatter** with `name` and `description` fields between `---` markers
- Write **style instructions** in the body -- tell Claude how to communicate
- Activate your style in `~/.claude/settings.json` by setting the `outputStyle` field

This is where you get creative. Pick a voice. Any voice. Pirate captain. Noir detective. Shakespearean scholar. Terse military briefing. A patient librarian who speaks only in well-organized lists. The point isn't realism -- it's understanding the format by building something memorable.

Or go practical. Some real possibilities:

- Concise and direct -- short answers, no filler, code over prose
- Explanatory -- teach as you go, explain the why behind decisions
- Structured -- headers, bullet points, clear sections for every response
- Opinionated -- take strong positions, recommend best practices, push back on bad ideas

The body of your output style is a system prompt. Write it like you're briefing someone on how to talk to you. And remember: the voice guiding you through these quests right now? That's this exact mechanism. Same frontmatter. Same directory pattern. The DM's mask is an output style too.

## Hints

### Hint 1

The file goes at `~/.claude/output-styles/hero-voice.md`. If the directory doesn't exist, create it.

### Hint 2

The frontmatter needs `name` and `description`. Here's the skeleton:

```markdown
---
name: my-style
description: Short description of what this style does
---

Your style instructions go here. Tell Claude how to format responses,
what tone to use, what to include or leave out.
```

This is the same `---` frontmatter pattern from your slash command in Level 3. Same incantation, different spell.

### Hint 3

Here's a complete example:

```markdown
---
name: concise
description: Minimal responses -- code over prose, skip the preamble
---

Keep responses short. Lead with code when the question is about code.
Skip introductory sentences. No "Sure!" or "Great question!".

Use bullet points for multi-part answers. One sentence per point.

When explaining, explain once. Don't rephrase the same idea.
```

To activate it, add this to `~/.claude/settings.json`:

```json
{
  "outputStyle": "concise"
}
```

The value matches the `name` field in the frontmatter.

## Verification

### Filesystem Check

- Path: `~/.claude/output-styles/hero-voice.md`
- Command: `test -f ~/.claude/output-styles/hero-voice.md && echo "exists" || echo "missing"`

### Content Check

- The file has valid YAML frontmatter (content between `---` delimiters at the top)
- Frontmatter contains a `name` field with a non-empty value
- Frontmatter contains a `description` field with a non-empty value
- The body below the frontmatter contains style instructions (not empty)

## Connection

The mask is forged. Your voice, your rules.

Three spells now. A slash command in Level 3. An output style here. And before all of it, a CLAUDE.md in Level 2. Notice something?

The `---` frontmatter. The markdown body. The file in the right place. Same incantation each time. This pattern is the grammar of the realm. Every extension point Claude Code offers speaks this language. Learn it once, use it everywhere.

Next, you'll learn to set traps that trigger without your hand on the wire. And that spell you forged back in the Goblin Lair? It's about to get a tripwire.
