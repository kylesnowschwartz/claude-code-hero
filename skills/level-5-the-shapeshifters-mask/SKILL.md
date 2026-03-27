---
name: level-5-the-shapeshifters-mask
description: "Claude Code Hero Level 5: The Shapeshifter's Mask -- create a custom output style in .claude/output-styles/"
---

## Objective

Create a custom **output style** at `.claude/output-styles/hero-voice.md` and activate it in your settings.

## Why This Matters

Output styles control how Claude communicates. Tone, structure, verbosity, formatting -- all of it. You've been experiencing one this entire time. The voice guiding you through these quests? That's an output style. A markdown file with frontmatter and instructions, sitting in a directory, shaping every word you've read.

Now you build your own.

## The Quest

You enter a chamber of masks. They line the walls, each one different. One speaks in terse commands. Another in long, careful explanations. A third in bullet points and nothing else.

You've been hearing a voice since you entered this dungeon. Steady. Second person. Dry. That voice is wearing a mask too.

Look at it: `output-styles/heroguide.md` in this plugin's directory. Open it. Read it. That's the mask you've been listening to. An `.md` file with **YAML frontmatter** and a body of instructions. The same pattern you used to build a slash command in Level 3.

Now forge your own. Every mask needs a name. Yours is `hero-voice`.

- Create `.claude/output-styles/hero-voice.md`
- Add **YAML frontmatter** with `name` and `description` fields between `---` markers
- Write **style instructions** in the body -- tell Claude how to communicate
- Activate your style using the `/config` menu

This is where you get creative. Pick a voice. Any voice. Pirate captain. Noir detective. Shakespearean scholar. Terse military briefing. A patient librarian who speaks only in well-organized lists. The point isn't realism -- it's understanding the format by building something memorable.

Or go practical. Some real possibilities:

- Concise and direct -- short answers, no filler, code over prose
- Explanatory -- teach as you go, explain the why behind decisions
- Structured -- headers, bullet points, clear sections for every response
- Opinionated -- take strong positions, recommend best practices, push back on bad ideas

The body of your output style is a system prompt. Write it like you're briefing someone on how to talk to you. And remember: the voice guiding you through these quests right now? That's this exact mechanism. Same frontmatter. Same directory pattern. The DM's mask is an output style too.

Once the file exists, you need to put it on. Type `/config` in your Claude Code prompt. An interactive menu appears. Use the **arrow keys** to navigate to **Output style**, press **Enter**, and select `hero-voice` from the list. That's how you wear a new mask.

But putting the mask on isn't enough. Config changes like output styles take effect on the *next* session, not the current one. You need to restart Claude Code. Here's the trick: type `/exit` to end the session, then run `claude --continue` in your terminal. That restarts Claude and picks up right where you left off -- same conversation, fresh config. Your new voice will be speaking by the time you get back.

`--continue` is worth remembering. Any time you change settings, install a plugin, or modify CLAUDE.md, a quick `/exit` + `claude --continue` reloads everything without losing context.

### Try it

Once you're back in the session, ask Claude anything. The response should sound different -- your voice, your rules. If you chose pirate captain, you should hear "arr." If you chose terse, you should get short answers. If it sounds the same as before, check that you selected `hero-voice` in `/config` and restarted.

## Hints

### Hint 1

The file goes at `.claude/output-styles/hero-voice.md`. If the directory doesn't exist, create it.

### Hint 2

The frontmatter needs `name` and `description`. Same `---` pattern from your slash command in Level 3:

```markdown
---
name: hero-voice
description: Short description of what this style does
---

Your style instructions go here. Tell Claude how to format responses,
what tone to use, what to include or leave out.
```

## Verification

When you're ready, run `/verify` to check your work.

### Filesystem Check

- Path: `.claude/output-styles/hero-voice.md`
- Command: `test -f .claude/output-styles/hero-voice.md && echo "exists" || echo "missing"`

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
