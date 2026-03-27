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

Your task:

- Open `~/.claude/settings.json`
- Add a `hooks` section
- Create at least one hook under one event
- The hook must have a `type` (start with `"command"`) and a `command` that contains the word "hero" -- this is how the dungeon knows your tripwire from one that was already here
- Test that the hook actually fires by triggering the event

The simplest approach: a `Stop` hook that logs to a hero-specific path. Something like `echo "hero hook fired at $(date)" >> /tmp/hero-hook-log.txt`. The command is real and useful for debugging. The "hero" in the path marks it as yours.

You can get sophisticated later -- for now, prove the mechanism works.

## Hints

### Hint 1

Hooks live in `settings.json` under the `hooks` key. Each event name is a key that maps to an array of hook objects.

```json
{
  "hooks": {
    "Stop": [
      ...
    ]
  }
}
```

### Hint 2

Each hook object needs at least `type` and `command`. The `type` tells Claude Code what kind of hook it is. Start with `"command"` -- it runs a shell command. Remember: the `command` string must contain the word "hero" so the dungeon can verify it's yours.

```json
{
  "hooks": {
    "Stop": [
      {
        "type": "command",
        "command": "echo 'hero hook fired' >> /tmp/hero-hook-log.txt"
      }
    ]
  }
}
```

You can also add a `matcher` field for `PreToolUse` and `PostToolUse` hooks to filter which tool triggers them (e.g., `"Bash"` to only match Bash tool use).

### Hint 3

Here's a complete, working configuration with two hooks:

```json
{
  "hooks": {
    "Stop": [
      {
        "type": "command",
        "command": "echo \"hero: Claude stopped at $(date)\" >> /tmp/hero-hook-log.txt"
      }
    ],
    "PreToolUse": [
      {
        "type": "command",
        "matcher": "Bash",
        "command": "echo \"hero: Bash tool invoked\" >> /tmp/hero-hook-log.txt"
      }
    ]
  }
}
```

After adding this, have Claude do something (ask it a question, run a command) and then check `/tmp/hero-hook-log.txt` to confirm the hooks fired.

To test: ask Claude a question, let it respond, then run `cat /tmp/hero-hook-log.txt`.

## Verification

### Filesystem Check

- Path: `~/.claude/settings.json`
- Command: `test -f ~/.claude/settings.json && echo "exists" || echo "missing"`
- The file must exist

### Content Check

- Command: `grep -q "hero" ~/.claude/settings.json && echo "found" || echo "missing"` (checks that "hero" appears in the hooks section)
- The file contains valid JSON
- A `hooks` object exists at the top level
- At least one event key exists inside `hooks` (e.g., `Stop`, `PreToolUse`, `PostToolUse`)
- That event key maps to an array containing at least one hook object
- The hook object contains both `type` and `command` fields
- The `type` field is `"command"`
- The `command` field contains "hero" in the string (e.g., a log path like `/tmp/hero-hook-log.txt`)

## Connection

Your traps are set. Events trigger. Responses fire. The cavern hums with mechanisms that activate on their own, responding to moments you defined.

But look at what you've built so far. Commands. Styles. Permissions. Hooks. Individual pieces, each powerful alone. What if you could bundle them into something that activates on its own, without being asked? Not a trap. Not a spell. A living thing -- with knowledge, voice, and purpose that Claude summons when the moment is right.
