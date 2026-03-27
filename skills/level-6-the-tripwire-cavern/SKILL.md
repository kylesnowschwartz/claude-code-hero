---
name: level-6-the-tripwire-cavern
description: "Claude Code Hero Level 6: The Tripwire Cavern -- add a working hook to settings.json"
---

## Objective

Add a working **hook** to `~/.claude/settings.json` that fires automatically on a Claude Code event.

## Why This Matters

Everything so far has been reactive. You type a command, Claude responds. You set a permission, Claude obeys. But hooks make Claude Code event-driven. They fire when something happens -- before a tool runs, after a tool completes, when a session ends -- and they can validate, log, transform, or extend behavior without you lifting a finger.

Hooks are the automation layer. They're also the hardest concept in this progression so far. Take it slow.

## The Quest

You descend into a cavern. The floor is wrong. Pressure plates everywhere, connected to mechanisms in the walls by thin wires. Step on one and something activates. Not an attack -- a response. Automated. Precise. Indifferent to who triggered it.

This is the hook system.

Hooks live in `~/.claude/settings.json` under the `hooks` key. They're organized by **event** -- the moment they fire. Each event maps to an array of hook objects that execute when that event occurs.

Three events to start with:

- **`PreToolUse`** -- fires before Claude uses a tool. You can validate, block, or modify.
- **`PostToolUse`** -- fires after a tool completes. You can inspect results or trigger follow-ups.
- **`Stop`** -- fires when Claude finishes a response. Good for linting, formatting, or cleanup.

There are others: `UserPromptSubmit`, `SessionStart`, `SessionEnd`, `Notification`. But start with the three above.

Remember the spell you forged in the Goblin Lair? `/hero-spell` -- your magic missile command. It's been sitting quietly in `~/.claude/commands/`, waiting to be invoked. Time to give it a tripwire.

Your task:

- Open `~/.claude/settings.json`
- Add a `hooks` section
- Create a **`UserPromptSubmit`** hook that detects when your spell is cast and triggers a notification
- The hook must have a `type` (start with `"command"`) and a `command` that contains the word "hero" -- this is how the dungeon knows your tripwire from one that was already here
- Test that the hook fires by invoking `/hero-spell` with a target

The hook should react to your Level 3 spell. A `UserPromptSubmit` hook fires when the user submits a prompt -- including slash commands. Use a `matcher` to filter for prompts containing "hero-spell", then trigger a notification.

On macOS: `osascript -e 'display notification "Magic Missile fired!" with title "Claude Code Hero"'`

Cross-platform fallback: `echo "hero: Magic Missile fired at $(date)" >> /tmp/hero-hook-log.txt`

Either approach works. The mechanism is the same -- an event fires, your hook reacts, and something happens in the world outside Claude's conversation.

## Hints

### Hint 1

Hooks live in `settings.json` under the `hooks` key. Each event name is a key that maps to an array of hook objects. For this quest, the event is `UserPromptSubmit` -- it fires when a prompt is submitted, including slash commands.

```json
{
  "hooks": {
    "UserPromptSubmit": [
      ...
    ]
  }
}
```

### Hint 2

Each hook object needs at least `type` and `command`. The `type` tells Claude Code what kind of hook it is. Start with `"command"` -- it runs a shell command. Add a `matcher` to filter which prompts trigger it. For `UserPromptSubmit`, the matcher tests against the prompt text. Remember: the `command` string must contain the word "hero" so the dungeon can verify it's yours.

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "type": "command",
        "matcher": "hero-spell",
        "command": "echo 'hero: Magic Missile fired!' >> /tmp/hero-hook-log.txt"
      }
    ]
  }
}
```

### Hint 3

Here's a complete, working configuration that reacts to your Level 3 spell:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "type": "command",
        "matcher": "hero-spell",
        "command": "echo \"hero: Magic Missile fired at $(date)\" >> /tmp/hero-hook-log.txt"
      }
    ]
  }
}
```

On macOS, you can swap the echo for a system notification:

```json
{
  "type": "command",
  "matcher": "hero-spell",
  "command": "osascript -e 'display notification \"hero: Magic Missile fired!\" with title \"Claude Code Hero\"'"
}
```

To test: invoke `/hero-spell the goblin king` in Claude Code, then check `/tmp/hero-hook-log.txt` or watch for the notification. If the hook fired, you've wired an event to an action.

## Verification

### Filesystem Check

- Path: `~/.claude/settings.json`
- Command: `test -f ~/.claude/settings.json && echo "exists" || echo "missing"`
- The file must exist

### Content Check

- Command: `grep -q "hero" ~/.claude/settings.json && echo "found" || echo "missing"` (checks that "hero" appears in the hooks section)
- The file contains valid JSON
- A `hooks` object exists at the top level
- At least one event key exists inside `hooks` (e.g., `UserPromptSubmit`, `Stop`, `PreToolUse`, `PostToolUse`)
- That event key maps to an array containing at least one hook object
- The hook object contains both `type` and `command` fields
- The `type` field is `"command"`
- The `command` field contains "hero" in the string (e.g., a log path like `/tmp/hero-hook-log.txt`)

## Connection

Your traps are set. Events trigger. Responses fire. A spell from Level 3 now has a tripwire from Level 6. The cavern hums with mechanisms that activate on their own, responding to moments you defined.

Look at what you've built so far. A command with `$ARGUMENTS`. An output style with a voice. A hook that reacts to the command. Each piece connects to the others. And the pattern keeps repeating.

Next: knowledge that awakens on its own. Not a trap. Not a spell. Something that surfaces when the situation demands it, without being asked.
